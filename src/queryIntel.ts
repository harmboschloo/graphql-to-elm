import {
  GraphQLSchema,
  GraphQLOutputType,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isListType,
  isLeafType,
  getNamedType,
  getNullableType
} from "graphql";
import { FinalOptions } from "./options";
import { readFile } from "./utils";
import * as debug from "./debug";

export interface QueryIntel {
  src: string;
  query: string;
  items: QueryIntelItem[];
  parentStack: QueryIntelItem[];
}

export interface QueryIntelItem {
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  children: number[];
}

export const readQueryIntel = (
  src: string,
  schema: GraphQLSchema,
  options: FinalOptions
): QueryIntel => {
  options.log(`reading query ${src}`);

  const query = readFile(src)
    .trim()
    .replace(/\r\n/g, "\n");

  return {
    ...getQueryIntel(query, schema, options),
    src
  };
};

export const getQueryIntel = (
  query: string,
  schema: GraphQLSchema,
  options: FinalOptions
): QueryIntel => {
  const queryDocument = parse(query);

  const errors = validate(schema, queryDocument);
  if (errors.length > 0) {
    throw errors[0];
  }

  const typeInfo = new TypeInfo(schema);
  const visitor = queryVisitor(query, typeInfo, options);

  visit(queryDocument, visitWithTypeInfo(typeInfo, visitor));

  return visitor.intel();
};

const queryVisitor = (
  query: string,
  typeInfo: TypeInfo,
  options: FinalOptions
) => {
  const intel: QueryIntel = {
    src: "",
    query,
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

  return {
    intel() {
      return intel;
    },
    enter(node) {
      debug.addLogIndent(1);
      debug.log(`enter ${node.kind} ${node.value}`);

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
      debug.log(`leave ${node.kind}`);

      if (isItemNode(node)) {
        intel.parentStack.pop();
      }

      debug.addLogIndent(-1);
    }
  };
};
