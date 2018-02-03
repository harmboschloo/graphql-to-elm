import { readFileSync, writeFileSync } from "fs";
import {
  GraphQLSchema,
  GraphQLOutputType,
  GraphQLNullableType,
  GraphQLNamedType,
  GraphQLNonNull,
  buildSchema,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isListType,
  isScalarType,
  isLeafType,
  isNullableType,
  getNamedType,
  getNullableType
} from "graphql";

export interface Options {
  schema: string;
  queries: string[];
}

export const graphqlToElm = (options: Options): void => {
  const schema = buildSchema(readFileSync(options.schema, "utf-8"));
  options.queries.forEach(queryToElm(schema, options));
};

const queryToElm = (schema: GraphQLSchema, options: Options) => (
  queryPath: string
): void => {
  const query = parse(readFileSync(queryPath, "utf-8"));

  const errors = validate(schema, query);

  if (errors.length > 0) {
    throw errors[0];
  }

  const typeInfo = new TypeInfo(schema);
  const visitor = queryVisitor(typeInfo);

  visit(query, visitWithTypeInfo(typeInfo, visitor));

  const queryIntel = visitor.intel();
  const elmIntel = queryToElmIntel(queryIntel.items);
  const elm = generateElm(elmIntel);

  writeFileSync(
    `${queryPath}.queryIntell.json`,
    JSON.stringify(queryIntel, null, "\t"),
    "utf-8"
  );
  writeFileSync(
    `${queryPath}.elmIntell.json`,
    JSON.stringify(elmIntel, null, "\t"),
    "utf-8"
  );
  writeFileSync(`${queryPath}.elm`, elm, "utf-8");
};

interface QueryIntel {
  items: QueryIntelItem[];
  parentStack: QueryIntelItem[];
}

interface QueryIntelItem {
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  children: number[];
}

const queryVisitor = (typeInfo: TypeInfo) => {
  const intel: QueryIntel = {
    items: [],
    parentStack: []
  };

  const getParentItem = () => {
    if (intel.parentStack.length > 0) {
      return intel.parentStack[intel.parentStack.length - 1];
    }
  };

  const isItemNode = node => {
    const { kind } = node;
    const type = typeInfo.getType();
    const nullableType = getNullableType(type);
    const namedType = getNamedType(type);
    return (
      (kind == Kind.OPERATION_DEFINITION || kind == Kind.FIELD) &&
      (isListType(nullableType) ||
        isCompositeType(namedType) ||
        isLeafType(namedType))
    );
  };

  let indent = 0;
  let pad = "";

  return {
    intel() {
      return intel;
    },
    enter(node) {
      pad += "  ";

      console.log(pad, "enter", node.kind, node.value);
      console.log(pad, "type", typeInfo.getType());
      console.log(pad, "name", node.name);
      // console.log("isNullableType", isNullableType(typeInfo.getType()));
      // console.log("nullableType", getNullableType(typeInfo.getType()));
      // console.log("fieldDef", typeInfo.getFieldDef());
      // console.log("inputType", typeInfo.getInputType());
      // console.log("selections", node.selections && node.selections.length);
      // console.log("node", node);

      if (isItemNode(node)) {
        const item = {
          id: intel.items.length,
          type: typeInfo.getType(),
          name: node.name && node.name.value,
          depth: intel.parentStack.length,
          children: []
        };

        const parent = getParentItem();
        if (parent) {
          parent.children.push(item.id);
        }

        intel.items.push(item);
        intel.parentStack.push(item);
      }
    },
    leave(node) {
      console.log(pad, "leave", node.kind);

      if (isItemNode(node)) {
        intel.parentStack.pop();
      }

      pad = pad.slice(0, -2);
    }
  };
};

interface ElmIntel {
  items: ElmIntelItem[];
  names: {};
  recordNames: {};
  recordDecoderNames: {};
}

interface ElmIntelItem {
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
  imports: string[];
}

const queryToElmIntel = (queryItems: QueryIntelItem[]): ElmIntel =>
  queryItems
    .sort((a, b) => b.depth - a.depth || b.id - a.id)
    .reduce(getElmIntel, {
      items: [],
      names: {},
      recordNames: {},
      recordDecoderNames: {}
    });

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
  const imports: string[] = [];

  if (isCompositeType(namedType)) {
    isRecordType = true;
    type = getRecordTypeName(namedType.toString(), children, intel);
    decoder = getRecordDecoderName(type, intel);
  } else if (isScalarType(nullableType)) {
    isRecordType = false;

    switch (nullableType.name) {
      case "Int":
        type = "Int";
        decoder = "Json.Decode.int";
        imports.push("Json.Decode");
        break;
      case "Float":
        type = "Float";
        decoder = "Json.Decode.float";
        imports.push("Json.Decode");
        break;
      case "Boolean":
        type = "Bool";
        decoder = "Json.Decode.bool";
        imports.push("Json.Decode");
        break;
      case "String":
        type = "String";
        decoder = "Json.Decode.string";
        imports.push("Json.Decode");
        break;
      case "ID": // FIXME
        type = "String";
        decoder = "Json.Decode.string";
        imports.push("Json.Decode");
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
      decoder,
      imports
    },
    intel
  );
};

const addItem = (item: ElmIntelItem, intel: ElmIntel): ElmIntel => ({
  ...intel,
  items: intel.items.concat(item)
});

const getChild = (id: number, intel: ElmIntel): ElmIntelItem => {
  const child = intel.items.find(item => item.id === id);
  if (!child) {
    throw new Error(`Could not find child item with id: ${id}`);
  }
  return child;
};

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
    const name = getName(type.charAt(0).toUpperCase() + type.slice(1), intel);
    intel.recordNames[signature] = name;
    return name;
  }
};

const getRecordDecoderName = (type: string, intel: ElmIntel) => {
  if (intel.recordDecoderNames[type]) {
    return intel.recordDecoderNames[type];
  } else {
    const name = getName(
      `${type.charAt(0).toLowerCase()}${type.slice(1)}Decoder`,
      intel
    );
    intel.recordDecoderNames[type] = name;
    return name;
  }
};

const getVariableName = (name: string, intel: ElmIntel): string =>
  getName(name.charAt(0).toLowerCase() + name.slice(1), intel);

// TODO

const generateElm = elmIntel => "module To.Do\n\n";

const getItemSignature = (item: ElmIntelItem): string => {
  let signature = item.type;
  if (item.isListMaybe) {
    signature = `Maybe ${signature}`;
  }
  if (item.isList) {
    signature = `List (${signature})`;
  }
  if (item.isMaybe) {
    signature = `Maybe (${signature})`;
  }
  return signature;
};
