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
import { FinalOptions } from "./options";
import { QueryIntel, QueryIntelItem } from "./queryIntel";
import { validModuleName, validTypeName, validVariableName } from "./utils";

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
    .reduce(getElmIntel, {
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

const getElmIntel = (intel: ElmIntel, queryItem: QueryIntelItem): ElmIntel => {
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

    switch (namedType.name) {
      case "Int":
        type = "Int";
        decoder = "Json.Decode.int";
        addImport("Json.Decode", intel);
        break;
      case "Float":
        type = "Float";
        decoder = "Json.Decode.float";
        addImport("Json.Decode", intel);
        break;
      case "Boolean":
        type = "Bool";
        decoder = "Json.Decode.bool";
        addImport("Json.Decode", intel);
        break;
      case "String":
        type = "String";
        decoder = "Json.Decode.string";
        addImport("Json.Decode", intel);
        break;
      case "ID": // FIXME
        type = "String";
        decoder = "Json.Decode.string";
        addImport("Json.Decode", intel);
        break;
      default:
        throw new Error(`Unhandled query scalar type: ${queryItem.type}`);
    }
  } else {
    throw new Error(`Unhandled query type: ${queryItem.type}`);
  }

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

const reservedWords = [
  "if",
  "then",
  "else",
  "case",
  "of",
  "let",
  "in",
  "type",
  "module",
  "where",
  "import",
  "exposing",
  "as",
  "port"
];

const getReservedNames = () =>
  ["Data", "query", "decoder"]
    .concat(reservedWords)
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
  intel.imports[name] = true;
};
