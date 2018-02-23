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
import { QueryIntel, QueryIntelItem, QueryIntelOutputItem } from "./queryIntel";
import {
  cachedValue,
  nextValidName,
  validNameUpper,
  validModuleName,
  validTypeName,
  validVariableName,
  validFieldName
} from "./utils";

export interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  usedNames: string[];
  recordsBySignature: { [signature: string]: string };
  encode: {
    items: ElmIntelEncodeItem[];
    encodersByRecordName: { [name: string]: string };
  };
  decode: {
    items: ElmIntelDecodeItem[];
    decodersByRecordName: { [name: string]: string };
  };
}

export interface ElmIntelItem {
  id: number;
  name: string;
  fieldName: string;
  depth: number;
  children: number[];
  isOptional: boolean;
  isListOfOptionals: boolean;
  isNullable: boolean;
  isList: boolean;
  isListOfNullables: boolean;
  type: string;
  kind: ElmIntelItemKind;
}

export type ElmIntelItemKind = "record" | "union" | "enum" | "scalar";

export interface ElmIntelEncodeItem extends ElmIntelItem {
  encoder: string;
}

export interface ElmIntelDecodeItem extends ElmIntelItem {
  decoder: string;
}

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
    recordsBySignature: {},
    encode: {
      items: [],
      encodersByRecordName: {}
    },
    decode: {
      items: [],
      decodersByRecordName: {}
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
    item = {
      ...info,
      kind: "record",
      type: "Variables",
      encoder: "encodeVariables"
    };
    setRecordFieldNames(item, intel.encode.items);
  } else if (isInputObjectType(namedType)) {
    const type = newRecordTypeName(
      namedType.name,
      info.children,
      intel.encode.items,
      intel
    );
    item = {
      ...info,
      kind: "record",
      type,
      encoder: newRecordEncoderName(type, intel)
    };
    setRecordFieldNames(item, intel.encode.items);
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
      item = {
        ...info,
        kind: "record",
        type: "Data",
        decoder: "decoder"
      };
      intel.recordsBySignature[""] = item.type;
      intel.decode.decodersByRecordName[item.type] = item.decoder;
      setRecordFieldNames(item, intel.decode.items);
    } else if (queryItem.fragmentChildren.length > 0) {
      item = {
        ...info,
        kind: "union",
        type: "FIXME",
        decoder: "FIXME"
      };
    } else {
      const type = newRecordTypeName(
        namedType.name,
        info.children,
        intel.decode.items,
        intel
      );
      item = {
        ...info,
        kind: "record",
        type,
        decoder: newRecordDecoderName(type, intel)
      };
      setRecordFieldNames(item, intel.decode.items);
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

const setRecordFieldNames = (item: ElmIntelItem, items: ElmIntelItem[]) => {
  if (item.children.length === 0) {
    throw new Error(`record item ${item.type} should have children`);
  }

  const usedFieldNames = [];
  item.children.map(findChildItemIn(items)).forEach(child => {
    if (!child) {
      throw new Error(`Could not find child of elm intel item: ${item.type}`);
    }
    child.fieldName = nextValidName(validFieldName(child.name), usedFieldNames);
  });
};

const newRecordTypeName = (
  type: string,
  children: number[],
  items: ElmIntelItem[],
  intel: ElmIntel
): string => {
  const propertySignatures = children
    .map(findChildItemIn(items))
    .map(item => `${item.name}:${item.type}`)
    .sort()
    .join(",");

  const signature = `${type}: ${propertySignatures}`;

  return cachedValue(signature, intel.recordsBySignature, () =>
    newName(validTypeName(type), intel)
  );
};

const newRecordEncoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.encode.encodersByRecordName, () =>
    newName(`encode${validNameUpper(type)}`, intel)
  );

const newRecordDecoderName = (type: string, intel: ElmIntel) =>
  cachedValue(type, intel.decode.decodersByRecordName, () =>
    newName(validVariableName(`${type}Decoder`), intel)
  );

export const findChildItemIn = <T extends ElmIntelItem>(items: T[]) => (
  childId: number
): T => {
  const child = items.find(item => item.id === childId);
  if (!child) {
    throw new Error(`Could not find elm intel child item with id: ${childId}`);
  }
  return child;
};
