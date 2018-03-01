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
  getMaxOrder,
  nextValidName,
  validNameUpper,
  validModuleName,
  validTypeName,
  validTypeConstructorName,
  validVariableName,
  validFieldName
} from "./utils";
import { QueryIntel, QueryIntelItem, QueryIntelOutputItem } from "./queryIntel";
import { wrappedType } from "./generateElm";
import {
  ElmIntel,
  ElmIntelItem,
  ElmIntelEncodeItem,
  ElmIntelDecodeItem
} from "./elmIntelTypes";

export * from "./elmIntelTypes";

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
    .sort((a, b) => b.depth - a.depth || a.order - b.order)
    .forEach(addEncodeItem(intel, options));

  let nextDecodeId = queryIntel.items.length;
  const getNextDecodeId = () => ++nextDecodeId;

  queryIntel.items
    .sort((a, b) => b.depth - a.depth || a.order - b.order)
    .forEach(addDecodeItem(intel, getNextDecodeId, options));

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
    setRecordFieldNames(info.children, intel.encode.items);
    item = {
      ...info,
      kind: "record",
      type: "Variables",
      encoder: "encodeVariables"
    };
  } else if (isInputObjectType(namedType)) {
    setRecordFieldNames(info.children, intel.encode.items);
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

const addDecodeItem = (
  intel: ElmIntel,
  nextId: () => number,
  options: FinalOptions
) => (queryItem: QueryIntelOutputItem): void => {
  const info = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  info.isOptional = queryItem.withDirective;

  let item: ElmIntelDecodeItem;

  if (isCompositeType(namedType)) {
    if (info.id === 0) {
      setRecordFieldNames(info.children, intel.decode.items);
      item = {
        ...info,
        kind: "record",
        type: "Data",
        decoder: "decoder",
        unionConstructor: ""
      };
      intel.typesBySignature[""] = item.type;
      intel.decode.decodersByType[item.type] = item.decoder;
    } else if (queryItem.isFragmented) {
      checkUnionChildSignatures(queryItem.children, intel.decode.items);

      const prefix = queryItem.isFragmentedOn ? "On" : "";
      const type = newUnionType(
        `${prefix}${namedType.name}`,
        info.children,
        intel
      );

      item = {
        ...info,
        kind: queryItem.isFragmentedOn ? "union-on" : "union",
        type,
        decoder: newDecoderName(type, intel),
        unionConstructor: ""
      };

      if (!queryItem.hasAllPosibleFragmentTypes) {
        const children = item.children.map(findByIdIn(intel.decode.items));
        const otherItem: ElmIntelDecodeItem = {
          id: nextId(),
          name: "",
          fieldName: "",
          order: getMaxOrder(children) + 0.5,
          children: [],
          isOptional: false,
          isListOfOptionals: false,
          isNullable: false,
          isList: false,
          isListOfNullables: false,
          kind: "empty",
          type: `Other${namedType.name}`,
          decoder: queryItem.isFragmentedOn
            ? "Json.Decode.succeed"
            : "GraphqlToElm.DecodeHelpers.emptyObjectDecoder",
          unionConstructor: ""
        };

        item.children.push(otherItem.id);
        intel.decode.items.push(otherItem);
      }

      setUnionConstructorNames(item, intel);
    } else {
      setRecordFieldNames(info.children, intel.decode.items);
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
        decoder: newDecoderName(type, intel),
        unionConstructor: ""
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
      decoder: scalarDecoder.decoder,
      unionConstructor: ""
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
      decoder: enumDecoder.decoder,
      unionConstructor: ""
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
    order: queryItem.order,
    children: queryItem.children.slice(),
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

const setRecordFieldNames = (fieldItems: number[], items: ElmIntelItem[]) => {
  const usedFieldNames = [];
  fieldItems.map(findByIdIn(items)).forEach(item => {
    if (!item.name) {
      throw new Error(`Elm intel field item ${item.type} does not have a name`);
    }
    item.fieldName = nextValidName(validFieldName(item.name), usedFieldNames);
  });
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

const getRecordFieldsSignature = (
  children: number[],
  items: ElmIntelItem[]
): string =>
  children
    .map(findByIdIn(items))
    .map(item => {
      if (!item.fieldName) {
        throw new Error(
          `Elm intel field item ${item.type} does not have a fieldName`
        );
      }
      return `${item.fieldName} : ${wrappedType(item)}`;
    })
    .sort()
    .join(", ");

const getRecordFieldsJsonSignature = (
  children: number[],
  items: ElmIntelItem[]
): string =>
  children
    .map(findByIdIn(items))
    .map(item => getRecordFieldJsonSignature(item, items))
    .sort()
    .join(", ");

const getRecordFieldJsonSignature = (
  item: ElmIntelItem,
  items: ElmIntelItem[]
): string => {
  if (!item.name) {
    throw new Error(`Elm intel field item ${item.type} does not have a name`);
  }

  let signature;

  if (item.kind === "record") {
    signature = `{${getRecordFieldsJsonSignature(item.children, items)}}`;
  } else {
    signature = item.type;
  }

  if (item.isList) {
    signature = `[${signature}]`;
  }

  return `${item.name} : ${signature}`;
};

const checkUnionChildSignatures = (
  children: number[],
  items: ElmIntelDecodeItem[]
) => {
  const childSignatures = children
    .map(findByIdIn(items))
    .map(item => getRecordFieldsJsonSignature(item.children, items));

  childSignatures.forEach((signatue, index) => {
    if (childSignatures.indexOf(signatue) !== index) {
      throw Error(
        `multiple union children with the same json signature: ${signatue}`
      );
    }
  });
};

const newUnionType = (
  type: string,
  children: number[],
  intel: ElmIntel
): string => {
  const childSignatures = children
    .map(findByIdIn(intel.decode.items))
    .map(item => item.type);

  const signature = `${type}: ${childSignatures.join(", ")}`;

  return cachedValue(signature, intel.typesBySignature, () =>
    newName(validTypeName(type), intel)
  );
};

const setUnionConstructorNames = (item: ElmIntelDecodeItem, intel: ElmIntel) =>
  item.children.map(findByIdIn(intel.decode.items)).forEach(child => {
    child.unionConstructor = newUnionConstructor(item.type, child.type, intel);
  });

const newUnionConstructor = (
  unionType: string,
  constructorType: string,
  intel: ElmIntel
): string =>
  cachedValue(`${unionType} On${constructorType}`, intel.typesBySignature, () =>
    newName(validTypeConstructorName(`On${constructorType}`), intel)
  );

const newEncoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.encode.encodersByType, () =>
    newName(`encode${validNameUpper(type)}`, intel)
  );

const newDecoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.decode.decodersByType, () =>
    newName(validVariableName(`${type}Decoder`), intel)
  );
