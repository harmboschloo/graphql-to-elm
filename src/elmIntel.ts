import * as path from "path";
import {
  GraphQLNullableType,
  GraphQLNamedType,
  isCompositeType,
  isInputObjectType,
  isListType,
  isScalarType,
  isEnumType,
  isNullableType,
  getNamedType,
  getNullableType
} from "graphql";
import {
  FinalOptions,
  TypeEncoders,
  TypeEncoder,
  TypeDecoders,
  TypeDecoder
} from "./options";
import {
  cachedValue,
  findByIdIn,
  nextValidName,
  validNameUpper,
  validModuleName,
  validTypeName,
  validVariableName,
  validFieldName
} from "./utils";
import { QueryIntel, QueryIntelItem, QueryIntelOutputItem } from "./queryIntel";
import { wrapType } from "./generateElm";
import {
  ElmIntel,
  ElmIntelItem,
  ElmIntelEncodeItem,
  ElmIntelDecodeItem
} from "./elmIntelTypes";

export const queryToElmIntel = (
  queryIntel: QueryIntel,
  options: FinalOptions
): ElmIntel => {
  let dest;
  let module;

  if (!queryIntel.src) {
    dest = "./Query.elm";
    module = "Query";
  } else {
    const srcPath = path.relative(options.src, queryIntel.src);
    const srcInfo = path.parse(srcPath);

    const moduleParts = srcInfo.dir
      .split(/[\\/]/)
      .filter(x => !!x)
      .concat(srcInfo.name)
      .map(validModuleName);

    dest = path.resolve(options.dest, ...moduleParts) + ".elm";
    module = moduleParts.join(".");
  }

  const intel: ElmIntel = {
    dest,
    module,
    query: queryIntel.query,
    usedNames: getReservedNames(),
    typesBySignature: {},
    encode: {
      items: [],
      encodersByType: {}
    },
    decode: {
      items: [],
      decodersByType: {}
    }
  };

  queryIntel.variables
    .sort((a, b) => b.depth - a.depth || b.id - a.id)
    .forEach(addEncodeItem(intel, options));

  queryIntel.items
    .sort((a, b) => b.depth - a.depth || b.id - a.id)
    .forEach(addDecodeItem(intel, options));

  return intel;
};

const addEncodeItem = (intel: ElmIntel, options: FinalOptions) => (
  queryItem: QueryIntelItem
): void => {
  const info = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  info.isOptional = info.isNullable;
  info.isListOfOptionals = info.isListOfNullables;

  let item: ElmIntelEncodeItem;

  if (info.id === 0) {
    setFieldNames(info.children, intel.encode.items);
    item = {
      ...info,
      kind: "record",
      type: "Variables",
      encoder: "encodeVariables"
    };
  } else if (isInputObjectType(namedType)) {
    setFieldNames(info.children, intel.encode.items);
    const type = newRecordType(
      namedType.name,
      info.children,
      intel.encode.items,
      intel
    );
    item = {
      ...info,
      kind: "record",
      type,
      encoder: newEncoderName(type, intel)
    };
  } else if (isScalarType(namedType)) {
    const scalarEncoder: TypeEncoder | undefined =
      options.scalarEncoders[namedType.name] ||
      defaultScalarEncoders[namedType.name];

    if (!scalarEncoder) {
      `No encoder defined for scalar type: ${
        queryItem.type
      }. Please add one to options.scalarEncoders`;
    }

    item = {
      ...info,
      kind: "scalar",
      type: scalarEncoder.type,
      encoder: scalarEncoder.encoder
    };
  } else if (isEnumType(namedType)) {
    const typeName: string = namedType.name;
    const enumEncoder: TypeEncoder | undefined = options.enumEncoders[typeName];

    if (!enumEncoder) {
      throw new Error(
        `No encoder defined for enum type: ${
          queryItem.type
        }. Please add one to options.enumEncoders`
      );
    }

    item = {
      ...info,
      kind: "enum",
      type: enumEncoder.type,
      encoder: enumEncoder.encoder
    };
  } else {
    throw new Error(`Unhandled query input type: ${queryItem.type}`);
  }

  intel.encode.items.push(item);
};

const addDecodeItem = (intel: ElmIntel, options: FinalOptions) => (
  queryItem: QueryIntelOutputItem
): void => {
  const info = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  info.isOptional = queryItem.withDirective;

  let item: ElmIntelDecodeItem;

  if (isCompositeType(namedType)) {
    if (info.id === 0) {
      setFieldNames(info.children, intel.decode.items);
      item = {
        ...info,
        kind: "record",
        type: "Data",
        decoder: "decoder"
      };
      intel.typesBySignature[""] = item.type;
      intel.decode.decodersByType[item.type] = item.decoder;
    } else if (queryItem.isFragmented) {
      const children = info.children.map(findByIdIn(intel.decode.items));
      const childSignatures = children.map(item =>
        getRecordFieldsSignature(item.children, intel.decode.items)
      );
      childSignatures.forEach((signatue, index) => {
        if (childSignatures.indexOf(signatue) !== index) {
          throw new Error(
            `multiple union constructors for ${
              namedType.name
            } with the same signature: ${signatue}`
          );
        }
      });

      const type = newUnionType(namedType.name, intel);
      item = {
        ...info,
        kind: "union",
        type,
        decoder: newDecoderName(type, intel)
      };
    } else {
      setFieldNames(info.children, intel.decode.items);
      const type = newRecordType(
        namedType.name,
        info.children,
        intel.decode.items,
        intel
      );
      item = {
        ...info,
        kind: "record",
        type,
        decoder: newDecoderName(type, intel)
      };
    }
  } else if (isScalarType(namedType)) {
    const scalarDecoder: TypeDecoder | undefined =
      options.scalarDecoders[namedType.name] ||
      defaultScalarDecoders[namedType.name];

    if (!scalarDecoder) {
      throw new Error(
        `No decoder defined for scalar type: ${
          queryItem.type
        }. Please add one to options.scalarDecoders`
      );
    }

    item = {
      ...info,
      kind: "scalar",
      type: scalarDecoder.type,
      decoder: scalarDecoder.decoder
    };
  } else if (isEnumType(namedType)) {
    const typeName: string = namedType.name;
    const enumDecoder: TypeDecoder | undefined = options.enumDecoders[typeName];

    if (!enumDecoder) {
      throw new Error(
        `No decoder defined for enum type: ${
          queryItem.type
        }. Please add one to options.enumDecoders`
      );
    }

    item = {
      ...info,
      kind: "enum",
      type: enumDecoder.type,
      decoder: enumDecoder.decoder
    };
  } else {
    throw new Error(`Unhandled query output type: ${queryItem.type}`);
  }

  intel.decode.items.push(item);
};

const defaultScalarEncoders: TypeEncoders = {
  Int: {
    type: "Int",
    encoder: "Json.Encode.int"
  },
  Float: {
    type: "Float",
    encoder: "Json.Encode.float"
  },
  Boolean: {
    type: "Bool",
    encoder: "Json.Encode.bool"
  },
  String: {
    type: "String",
    encoder: "Json.Encode.string"
  },
  ID: {
    type: "String",
    encoder: "Json.Encode.string"
  }
};

const defaultScalarDecoders: TypeDecoders = {
  Int: {
    type: "Int",
    decoder: "Json.Decode.int"
  },
  Float: {
    type: "Float",
    decoder: "Json.Decode.float"
  },
  Boolean: {
    type: "Bool",
    decoder: "Json.Decode.bool"
  },
  String: {
    type: "String",
    decoder: "Json.Decode.string"
  },
  ID: {
    type: "String",
    decoder: "Json.Decode.string"
  }
};

const getItemInfo = (queryItem: QueryIntelItem) => {
  const nullableType: GraphQLNullableType = getNullableType(queryItem.type);
  const isList = isListType(nullableType);

  return {
    id: queryItem.id,
    name: queryItem.name,
    fieldName: "",
    depth: queryItem.depth,
    children: queryItem.children,
    isOptional: false,
    isListOfOptionals: false,
    isNullable: isNullableType(queryItem.type),
    isList,
    isListOfNullables: isList && isNullableType(nullableType.ofType)
  };
};

const reservedNames = [
  "Variables",
  "Data",
  "query",
  "encodeVariables",
  "decoder"
];

const getReservedNames = () => [...reservedNames];

const newName = (name: string, intel: ElmIntel): string =>
  nextValidName(name, intel.usedNames);

const setFieldNames = (fieldItems: number[], items: ElmIntelItem[]) => {
  const usedFieldNames = [];
  fieldItems.map(findByIdIn(items)).forEach(item => {
    if (!item.name) {
      throw new Error(`Elm intel field item ${item.type} does not have a name`);
    }
    item.fieldName = nextValidName(validFieldName(item.name), usedFieldNames);
  });
};

const getRecordFieldsSignature = (
  children: number[],
  items: ElmIntelItem[]
): string => {
  return children
    .map(findByIdIn(items))
    .map(item => {
      if (!item.fieldName) {
        throw new Error(
          `Elm intel field item ${item.type} does not have a fieldName`
        );
      }
      return `${item.fieldName} : ${wrapType(item)}`;
    })
    .sort()
    .join(", ");
};

const newRecordType = (
  graphqlType: string,
  children: number[],
  items: ElmIntelItem[],
  intel: ElmIntel
): string => {
  let signature = `${graphqlType}: ${getRecordFieldsSignature(
    children,
    items
  )}`;

  return cachedValue(signature, intel.typesBySignature, () =>
    newName(validTypeName(graphqlType), intel)
  );
};

const newUnionType = (graphqlType: string, intel: ElmIntel): string => {
  const signature = graphqlType;

  return cachedValue(signature, intel.typesBySignature, () =>
    newName(validTypeName(`${graphqlType}Union`), intel)
  );
};

const newEncoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.encode.encodersByType, () =>
    newName(`encode${validNameUpper(type)}`, intel)
  );

const newDecoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.decode.decodersByType, () =>
    newName(validVariableName(`${type}Decoder`), intel)
  );
