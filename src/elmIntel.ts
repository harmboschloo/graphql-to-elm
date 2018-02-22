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
  encode: {
    items: ElmIntelEncodeItem[];
  };
  decode: {
    items: ElmIntelDecodeItem[];
    recordNamesBySignature: {};
    decoderNamesByRecordName: {};
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
    encode: {
      items: []
    },
    decode: {
      items: [],
      recordNamesBySignature: {},
      decoderNamesByRecordName: {}
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
    const type = newEncodeRecordTypeName(namedType.name, intel);
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
      setRecordFieldNames(item, intel.decode.items);
      intel.decode.recordNamesBySignature[""] = item.type;
      intel.decode.decoderNamesByRecordName[item.type] = item.decoder;
    } else if (queryItem.fragmentChildren.length > 0) {
      item = {
        ...info,
        kind: "union",
        type: "FIXME",
        decoder: "FIXME"
      };
    } else {
      const type = newDecodeRecordTypeName(
        namedType.name,
        info.children,
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
  const findItem = id => items.find(item => item.id === id);
  item.children.map(findItem).forEach(child => {
    if (!child) {
      throw new Error(`Could not find child of elm intel item: ${item.type}`);
    }
    child.fieldName = nextValidName(validFieldName(child.name), usedFieldNames);
  });
};

const newEncodeRecordTypeName = (type: string, intel: ElmIntel): string =>
  newName(validTypeName(type), intel);

const newRecordEncoderName = (type: string, intel: ElmIntel) =>
  newName(`encode${validNameUpper(type)}`, intel);

export const getEncodeItemChild = (
  id: number,
  intel: ElmIntel
): ElmIntelEncodeItem => {
  const child = intel.encode.items.find(item => item.id === id);
  if (!child) {
    throw new Error(
      `Could not find elm intel encode item child with id: ${id}`
    );
  }
  return child;
};

const newDecodeRecordTypeName = (
  type: string,
  children: number[],
  intel: ElmIntel
): string => {
  const propertyNames = children
    .map(id => getDecodeItemChild(id, intel).name)
    .sort()
    .join(",");

  const signature = `${type}: ${propertyNames}`;

  if (intel.decode.recordNamesBySignature[signature]) {
    return intel.decode.recordNamesBySignature[signature];
  } else {
    const name = newName(validTypeName(type), intel);
    intel.decode.recordNamesBySignature[signature] = name;
    return name;
  }
};

const newRecordDecoderName = (type: string, intel: ElmIntel) => {
  if (intel.decode.decoderNamesByRecordName[type]) {
    return intel.decode.decoderNamesByRecordName[type];
  } else {
    const name = newName(validVariableName(`${type}Decoder`), intel);
    intel.decode.decoderNamesByRecordName[type] = name;
    return name;
  }
};

export const getDecodeItemChild = (
  id: number,
  intel: ElmIntel
): ElmIntelDecodeItem => {
  const child = intel.decode.items.find(item => item.id === id);
  if (!child) {
    throw new Error(
      `Could not find elm intel decode item child with id: ${id}`
    );
  }
  return child;
};
