import * as path from "path";
import * as assert from "assert";
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
  isNullable: boolean;
  isList: boolean;
  isListOfNullables: boolean;
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
  const item = getItemInfo(queryItem);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  let type;
  let encoder;

  if (item.id === 0) {
    assert.ok(item.children.length > 0, "Variables should have children");
    item.isRecordType = true;
    type = "Variables";
    encoder = "encodeVariables";
    setRecordFieldNames(item, intel.encode.items);
  } else if (isInputObjectType(namedType)) {
    assert.ok(item.children.length > 0, "InputObjectType should have children");
    item.isRecordType = true;
    type = getEncodeRecordTypeName(namedType.name, intel);
    encoder = getRecordEncoderName(type, intel);
    setRecordFieldNames(item, intel.encode.items);
  } else if (isScalarType(namedType)) {
    const scalarEncoder: TypeEncoder | undefined =
      options.scalarEncoders[namedType.name] ||
      defaultScalarEncoders[namedType.name];

    assert.ok(
      scalarEncoder,
      `No encoder defined for scalar type: ${
        queryItem.type
      }. Please add one to options.scalarEncoders`
    );

    type = scalarEncoder.type;
    encoder = scalarEncoder.encoder;
  } else if (isEnumType(namedType)) {
    const typeName: string = namedType.name;
    const enumEncoder: TypeEncoder | undefined = options.enumEncoders[typeName];

    assert.ok(
      enumEncoder,
      `No encoder defined for enum type: ${
        queryItem.type
      }. Please add one to options.enumEncoders`
    );

    type = enumEncoder.type;
    encoder = enumEncoder.encoder;
  } else {
    assert.fail(`Unhandled query type: ${queryItem.type}`);
  }

  intel.encode.items.push({
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
    assert.ok(item.children.length > 0, "CompositeType should have children");
    item.isRecordType = true;
    setRecordFieldNames(item, intel.decode.items);
    if (item.id === 0) {
      type = "Data";
      decoder = "decoder";
      intel.decode.recordNamesBySignature[""] = type;
      intel.decode.decoderNamesByRecordName[type] = decoder;
    } else {
      type = getDecodeRecordTypeName(namedType.name, item.children, intel);
      decoder = getRecordDecoderName(type, intel);
    }
  } else if (isScalarType(namedType)) {
    const scalarDecoder: TypeDecoder | undefined =
      options.scalarDecoders[namedType.name] ||
      defaultScalarDecoders[namedType.name];

    assert.ok(
      scalarDecoder,
      `No decoder defined for scalar type: ${
        queryItem.type
      }. Please add one to options.scalarDecoders`
    );

    type = scalarDecoder.type;
    decoder = scalarDecoder.decoder;
  } else if (isEnumType(namedType)) {
    const typeName: string = namedType.name;
    const enumDecoder: TypeDecoder | undefined = options.enumDecoders[typeName];

    assert.ok(
      enumDecoder,
      `No decoder defined for enum type: ${
        queryItem.type
      }. Please add one to options.enumDecoders`
    );

    type = enumDecoder.type;
    decoder = enumDecoder.decoder;
  } else {
    assert.fail(`Unhandled query type: ${queryItem.type}`);
  }

  intel.decode.items.push({
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

const getItemInfo = (queryItem: QueryIntelItem): ElmIntelItem => {
  const nullableType: GraphQLNullableType = getNullableType(queryItem.type);
  const isList = isListType(nullableType);

  return {
    id: queryItem.id,
    name: queryItem.name,
    fieldName: "",
    depth: queryItem.depth,
    children: queryItem.children,
    isNullable: isNullableType(queryItem.type),
    isList,
    isListOfNullables: isList && isNullableType(nullableType.ofType),
    type: "",
    isRecordType: false
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

const getName = (name: string, intel: ElmIntel): string =>
  nextValidName(name, intel.usedNames);

const setRecordFieldNames = (
  { children }: ElmIntelItem,
  items: ElmIntelItem[]
) => {
  const usedFieldNames = [];
  const findItem = id => items.find(item => item.id === id);
  children.map(findItem).forEach(child => {
    if (child) {
      child.fieldName = nextValidName(
        validFieldName(child.name),
        usedFieldNames
      );
    } else {
      assert.fail("Could not find elm intel item child with id: ${id}");
    }
  });
};

const getEncodeRecordTypeName = (type: string, intel: ElmIntel): string =>
  getName(validTypeName(type), intel);

const getRecordEncoderName = (type: string, intel: ElmIntel) =>
  getName(`encode${validNameUpper(type)}`, intel);

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

  if (intel.decode.recordNamesBySignature[signature]) {
    return intel.decode.recordNamesBySignature[signature];
  } else {
    const name = getName(validTypeName(type), intel);
    intel.decode.recordNamesBySignature[signature] = name;
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

const getRecordDecoderName = (type: string, intel: ElmIntel) => {
  if (intel.decode.decoderNamesByRecordName[type]) {
    return intel.decode.decoderNamesByRecordName[type];
  } else {
    const name = getName(validVariableName(`${type}Decoder`), intel);
    intel.decode.decoderNamesByRecordName[type] = name;
    return name;
  }
};
