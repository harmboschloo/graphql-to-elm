import * as path from "path";
import {
  GraphQLNullableType,
  GraphQLNamedType,
  isCompositeType,
  isListType,
  isScalarType,
  isNullableType,
  getNamedType,
  getNullableType
} from "graphql";
import { FinalOptions, ScalarDecoders, ScalarDecoder } from "./options";
import { QueryIntel, QueryIntelItem } from "./queryIntel";
import {
  validModuleName,
  validTypeName,
  validVariableName,
  extractModule
} from "./utils";

export interface ElmIntel {
  dest: string;
  module: string;
  query: string;
  items: ElmIntelItem[];
  names: {};
  recordNames: {};
  recordDecoderNames: {};
  imports: {};
}

export interface ElmIntelItem {
  id: number;
  name: string;
  depth: number;
  children: number[];
  isMaybe: boolean;
  isList: boolean;
  isListMaybe: boolean;
  type: string;
  isRecordType: boolean;
  decoder: string;
}

export const getChild = (id: number, intel: ElmIntel): ElmIntelItem => {
  const child = intel.items.find(item => item.id === id);
  if (!child) {
    throw new Error(`Could not find elm intel child item with id: ${id}`);
  }
  return child;
};

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

  return queryIntel.items
    .sort((a, b) => b.depth - a.depth || b.id - a.id)
    .reduce(getElmIntel(options), {
      dest,
      module,
      query: queryIntel.query,
      items: [],
      names: getReservedNames(),
      recordNames: {},
      recordDecoderNames: {},
      imports: {}
    });
};

const getElmIntel = (options: FinalOptions) => (
  intel: ElmIntel,
  queryItem: QueryIntelItem
): ElmIntel => {
  const nullableType: GraphQLNullableType = getNullableType(queryItem.type);
  const namedType: GraphQLNamedType = getNamedType(queryItem.type);

  const id = queryItem.id;
  const name = queryItem.name;
  const depth = queryItem.depth;
  const children = queryItem.children;
  const isMaybe = isNullableType(queryItem.type);
  const isList = isListType(nullableType);
  const isListMaybe = isList && isNullableType(nullableType.ofType);
  let type;
  let isRecordType;
  let decoder;

  if (isCompositeType(namedType)) {
    isRecordType = true;
    if (id === 0) {
      type = "Data";
      decoder = "decoder";
      intel.recordNames[""] = type;
      intel.recordDecoderNames[type] = decoder;
    } else {
      type = getRecordTypeName(namedType.toString(), children, intel);
      decoder = getRecordDecoderName(type, intel);
    }
  } else if (isScalarType(namedType)) {
    isRecordType = false;
    const typeName: string = namedType.name;

    const scalarDecoder: ScalarDecoder | undefined =
      options.scalarDecoders[typeName] || defaultScalarDecoders[typeName];

    if (!scalarDecoder) {
      throw new Error(
        `No decoder defined for scalar type: ${
          queryItem.type
        }. Please add one to options.scalarDecoders`
      );
    }

    type = scalarDecoder.type;
    decoder = scalarDecoder.decoder;
    addImport(extractModule(type), intel);
    addImport(extractModule(decoder), intel);
  } else {
    throw new Error(`Unhandled query type: ${queryItem.type}`);
  }

  addImport("Json.Decode", intel);

  return addItem(
    {
      id,
      name,
      depth,
      children,
      isMaybe,
      isList,
      isListMaybe,
      type,
      isRecordType,
      decoder
    },
    intel
  );
};

const defaultScalarDecoders: ScalarDecoders = {
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

const reservedWordsElm = [
  "alias",
  "as",
  "case",
  "command",
  "effect",
  "else",
  "exposing",
  "false",
  "if",
  "import",
  "in",
  "infix",
  "left",
  "let",
  "module",
  "non",
  "null",
  "of",
  "port",
  "right",
  "subscription",
  "then",
  "type",
  "true",
  "where"
];

const reservedWords = ["Data", "query", "decoder"];

const getReservedNames = () =>
  reservedWords
    .concat(reservedWordsElm)
    .reduce((names, name) => ({ ...names, [name]: true }), {});

const addItem = (item: ElmIntelItem, intel: ElmIntel): ElmIntel => ({
  ...intel,
  items: intel.items.concat(item)
});

const getName = (name: string, intel: ElmIntel): string => {
  if (!intel.names[name]) {
    intel.names[name] = true;
    return name;
  } else {
    let count = 2;
    while (intel.names[name + count]) {
      count++;
    }
    const name2 = name + count;
    intel.names[name2] = true;
    return name2;
  }
};

const getRecordTypeName = (
  type: string,
  children: number[],
  intel: ElmIntel
): string => {
  const propertyNames = children
    .map(id => getChild(id, intel).name)
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
