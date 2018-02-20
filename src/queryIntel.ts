import {
  GraphQLSchema,
  GraphQLOutputType,
  GraphQLInputType,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isListType,
  isLeafType,
  isInputObjectType,
  getNamedType,
  getNullableType
} from "graphql";
import { FinalOptions } from "./options";
import { readFile } from "./utils";
import * as debug from "./debug";

export interface QueryIntel {
  src: string;
  query: string;
  variables: QueryIntelItem[];
  items: QueryIntelItem[];
  parentStack: QueryIntelItem[];
}

export interface QueryIntelItem {
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  withDirective: boolean;
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
    variables: [],
    items: [],
    parentStack: []
  };

  const getParentItem = () => {
    if (intel.parentStack.length > 0) {
      return intel.parentStack[intel.parentStack.length - 1];
    }
  };

  const addVariable = ({
    type,
    name,
    parent
  }: {
    type: GraphQLInputType;
    name: string;
    parent: QueryIntelItem;
  }) => {
    const item = {
      id: intel.variables.length,
      type,
      name,
      depth: parent.depth + 1,
      withDirective: false,
      children: []
    };

    intel.variables.push(item);
    parent.children.push(item.id);

    const namedType = getNamedType(type);
    if (isInputObjectType(namedType)) {
      const fields = namedType.getFields();
      Object.keys(fields).forEach(fieldName =>
        addVariable({
          type: fields[fieldName].type,
          name: fieldName,
          parent: item
        })
      );
    }
  };

  const isItemNode = node => {
    const { kind } = node;
    const type = typeInfo.getType();
    const nullableType = getNullableType(type);
    const namedType = getNamedType(type);
    return (
      (kind === Kind.OPERATION_DEFINITION || kind === Kind.FIELD) &&
      (isListType(nullableType) ||
        isCompositeType(namedType) ||
        isLeafType(namedType))
    );
  };

  return {
    intel() {
      return intel;
    },

    enter(node, key, parent) {
      debug.addLogIndent(1);
      debug.log(`enter ${node.kind} ${node.value}`);

      if (node.kind === Kind.VARIABLE_DEFINITION) {
        if (intel.variables.length === 0) {
          intel.variables.push({
            id: 0,
            type: "",
            name: "",
            depth: 0,
            withDirective: false,
            children: []
          });
        }

        addVariable({
          type: typeInfo.getInputType(),
          name: node.variable.name.value,
          parent: intel.variables[0]
        });
      }

      if (isItemNode(node)) {
        const item = {
          id: intel.items.length,
          type: typeInfo.getType(),
          name: node.name && node.name.value,
          depth: intel.parentStack.length,
          withDirective: node.directives && node.directives.length > 0,
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
