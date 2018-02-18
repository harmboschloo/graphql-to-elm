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
import { QueryIntel, QueryIntelItem } from "./queryIntel";
import {
  nextValidName,
  validNameUpper,
  validModuleName,
  validTypeName,
  validVariableName,
  validFieldName,
  extractModule
} from "./utils";

export interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  encodeItems: ElmIntelEncodeItem[];
  decodeItems: ElmIntelDecodeItem[];
  usedNames: string[];
  recordNames: {};
  recordDecoderNames: {};
  imports: {};
}

export interface ElmIntelItem {
  id: number;
  name: string;
  fieldName: string;
  depth: number;
  children: number[];
  isMaybe: boolean;
  isList: boolean;
  isListMaybe: boolean;
  type: string;
  isRecordType: boolean;
}

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
    decodeItems: [],
    encodeItems: [],
    usedNames: getReservedNames(),
    recordNames: {},
    recordDecoderNames: {},
    imports: {}
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
  const item = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  let type;
  let encoder;

  if (item.id === 0) {
    item.isRecordType = true;
    type = "Variables";
    encoder = "encodeVariables";
  } else if (isInputObjectType(namedType)) {
    item.isRecordType = true;
    type = getEncodeRecordTypeName(namedType.name, intel);
    encoder = getRecordEncoderName(type, intel);
  } else if (isScalarType(namedType)) {
    const scalarEncoder: TypeEncoder | undefined =
      options.scalarEncoders[namedType.name] ||
      defaultScalarEncoders[namedType.name];

    if (!scalarEncoder) {
      throw new Error(
        `No encoder defined for scalar type: ${
          queryItem.type
        }. Please add one to options.scalarEncoders`
      );
    }

    type = scalarEncoder.type;
    encoder = scalarEncoder.encoder;
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

    type = enumEncoder.type;
    encoder = enumEncoder.encoder;
  } else {
    throw new Error(`Unhandled query type: ${queryItem.type}`);
  }

  addImport("Json.Encode", intel);
  addImport(extractModule(type), intel);
  addImport(extractModule(encoder), intel);

  intel.encodeItems.push({
    ...item,
    type,
    encoder
  });
};

const addDecodeItem = (intel: ElmIntel, options: FinalOptions) => (
  queryItem: QueryIntelItem
): void => {
  const item = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  let type;
  let decoder;

  if (isCompositeType(namedType)) {
    item.isRecordType = true;
    setFieldNames(item, intel.decodeItems);
    if (item.id === 0) {
      type = "Data";
      decoder = "decoder";
      intel.recordNames[""] = type;
      intel.recordDecoderNames[type] = decoder;
    } else {
      type = getDecodeRecordTypeName(namedType.name, item.children, intel);
      decoder = getRecordDecoderName(type, intel);
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

    type = scalarDecoder.type;
    decoder = scalarDecoder.decoder;
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

    type = enumDecoder.type;
    decoder = enumDecoder.decoder;
  } else {
    throw new Error(`Unhandled query type: ${queryItem.type}`);
  }

  addImport("Json.Decode", intel);
  addImport(extractModule(type), intel);
  addImport(extractModule(decoder), intel);

  intel.decodeItems.push({
    ...item,
    type,
    decoder
  });
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

const reservedNames = [
  "Variables",
  "Data",
  "query",
  "encodeVariables",
  "decoder"
];

const getReservedNames = () => [...reservedNames];

const getItemInfo = (queryItem: QueryIntelItem): ElmIntelItem => {
  const nullableType: GraphQLNullableType = getNullableType(queryItem.type);
  const isList = isListType(nullableType);

  return {
    id: queryItem.id,
    name: queryItem.name,
    fieldName: "",
    depth: queryItem.depth,
    children: queryItem.children,
    isMaybe: isNullableType(queryItem.type),
    isList,
    isListMaybe: isList && isNullableType(nullableType.ofType),
    type: "",
    isRecordType: false
  };
};

const getName = (name: string, intel: ElmIntel): string =>
  nextValidName(name, intel.usedNames);

const setFieldNames = ({ children }: ElmIntelItem, items: ElmIntelItem[]) => {
  const usedFieldNames = [];
  const findItem = id => items.find(item => item.id === id);
  children.map(findItem).forEach(child => {
    if (child) {
      child.fieldName = nextValidName(
        validFieldName(child.name),
        usedFieldNames
      );
    }
  });
};

const getEncodeRecordTypeName = (type: string, intel: ElmIntel): string =>
  getName(validTypeName(type), intel);

const getDecodeRecordTypeName = (
  type: string,
  children: number[],
  intel: ElmIntel
): string => {
  const propertyNames = children
    .map(id => getDecodeItemChild(id, intel).name)
    .sort()
    .join(",");

  const signature = `${type}: ${propertyNames}`;

  if (intel.recordNames[signature]) {
    return intel.recordNames[signature];
  } else {
    const name = getName(validTypeName(type), intel);
    intel.recordNames[signature] = name;
    return name;
  }
};

export const getDecodeItemChild = (
  id: number,
  intel: ElmIntel
): ElmIntelDecodeItem => {
  const child = intel.decodeItems.find(item => item.id === id);
  if (!child) {
    throw new Error(
      `Could not find elm intel decode item child with id: ${id}`
    );
  }
  return child;
};

const getRecordEncoderName = (type: string, intel: ElmIntel) =>
  getName(`encode${validNameUpper(type)}`, intel);

const getRecordDecoderName = (type: string, intel: ElmIntel) => {
  if (intel.recordDecoderNames[type]) {
    return intel.recordDecoderNames[type];
  } else {
    const name = getName(validVariableName(`${type}Decoder`), intel);
    intel.recordDecoderNames[type] = name;
    return name;
  }
};

const addImport = (name: string, intel: ElmIntel) => {
  if (name) {
    intel.imports[name] = true;
  }
};
