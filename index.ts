import { readFileSync, writeFileSync } from "fs";
import {
  GraphQLSchema,
  GraphQLOutputType,
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

  const queryIntel = visitor.queryIntel();
  const elmIntel = queryToElmIntell(visitor.queryIntel());
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
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  children: number[];
}

const queryVisitor = (typeInfo: TypeInfo) => {
  const queryIntel: QueryIntel[] = [];
  const parentRecordStack: QueryIntel[] = [];
  const getParentRecord = () => {
    if (parentRecordStack.length > 0) {
      return parentRecordStack[parentRecordStack.length - 1];
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
    queryIntel() {
      return queryIntel;
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
          id: queryIntel.length,
          type: typeInfo.getType(),
          name: node.name && node.name.value,
          depth: parentRecordStack.length,
          children: []
        };

        const parent = getParentRecord();
        if (parent) {
          parent.children.push(item.id);
        }

        queryIntel.push(item);
        parentRecordStack.push(item);
      }
    },
    leave(node) {
      console.log(pad, "leave", node.kind);

      if (isItemNode(node)) {
        parentRecordStack.pop();
      }

      pad = pad.slice(0, -2);
    }
  };
};

const queryToElmIntell = queryIntel => {
  const itemsById = queryIntel.reduce(
    (acc, item) => ({ ...acc, [item.id]: item }),
    {}
  );

  const getItemById = (id: number): any => {
    const item = itemsById[id];
    if (!item) {
      throw new Error(`Could not find item with id: ${id}`);
    }
    return item;
  };

  const items = queryIntel
    .sort((a, b) => b.depth - a.depth)
    .map(a => ({ ...a, signature: a.children }))
    .map(item => ({
      ...item,
      signature: toElmType(item.type, item, getItemById)
    }));

  // .filter(a => a.children && a.children.length);

  // const recordsByName = records.reduce((acc, record) => {
  //   const recordType
  //   return acc;s
  // }, {});

  return items;
};

const toElmType = (type, item, getItemById) => {
  const nullableType = getNullableType(type);

  if (isNullableType(type)) {
    return `Maybe (${toElmType(
      GraphQLNonNull(nullableType),
      item,
      getItemById
    )})`;
  }

  if (isListType(nullableType)) {
    return `List (${toElmType(nullableType.ofType, item, getItemById)})`;
  }

  if (isCompositeType(nullableType)) {
    return `{${item.children
      .map(getItemById)
      .map(item => `${item.name}: ${toElmType(item.type, item, getItemById)}`)
      .join(", ")}}`;
  }

  if (isScalarType(nullableType)) {
    switch (nullableType.name) {
      case "Int":
        return "Int";
      case "Float":
        return "Float";
      case "Boolean":
        return "Bool";
      case "String":
        return "String";
      case "ID": // FIXME
        return "String";
    }
  }

  throw new Error(
    `Unhandled type: ${type}/${isListType(type)}/${JSON.stringify(item)}`
  );
};

const generateElm = elmIntel => "module To.Do\n\n";
