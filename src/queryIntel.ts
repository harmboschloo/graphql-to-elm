import {
  GraphQLSchema,
  GraphQLOutputType,
  GraphQLInputType,
  GraphQLNonNull,
  GraphQLNamedType,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isUnionType,
  isInterfaceType,
  isObjectType,
  isListType,
  isLeafType,
  isInputObjectType,
  getNamedType,
  getNullableType
} from "graphql";
import { FinalOptions } from "./options";
import { readFile, findByIdIn, getId, getMaxOrder } from "./utils";
import * as debug from "./debug";

export interface QueryIntel {
  src: string;
  query: string;
  variables: QueryIntelItem[];
  items: QueryIntelOutputItem[];
  parentStack: QueryIntelOutputItem[];
}

export interface QueryIntelItem {
  id: number;
  type: GraphQLOutputType;
  name: string;
  depth: number;
  order: number;
  children: number[];
}

export interface QueryIntelOutputItem extends QueryIntelItem {
  withDirective: boolean;
  isFragment: boolean;
  isFragmented: boolean;
  isFragmentedOn: boolean;
  hasAllPosibleFragmentTypes: boolean;
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
  const visitor = queryVisitor(query, typeInfo, schema, options);

  visit(queryDocument, visitWithTypeInfo(typeInfo, visitor));

  // console.log("query intel", JSON.stringify(visitor.intel(), null, "  "));

  return visitor.intel();
};

const queryVisitor = (
  query: string,
  typeInfo: TypeInfo,
  schema: GraphQLSchema,
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
    const id = intel.variables.length;
    const item = {
      id,
      type,
      name,
      depth: parent.depth + 1,
      order: id,
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

  const isItemNode = node =>
    node.kind === Kind.OPERATION_DEFINITION ||
    node.kind === Kind.FIELD ||
    isFragmentNode(node);

  const isFragmentNode = node => node.kind === Kind.INLINE_FRAGMENT;

  return {
    intel() {
      return intel;
    },

    enter(node, key, parent) {
      debug.addLogIndent(1);
      debug.log(
        `enter ${node.kind} ${node.value} ${typeInfo.getType() ||
          typeInfo.getInputType()}`
      );

      if (node.kind === Kind.VARIABLE_DEFINITION) {
        if (intel.variables.length === 0) {
          intel.variables.push({
            id: 0,
            type: "",
            name: "",
            depth: 0,
            order: 0,
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
        const type = typeInfo.getType();

        const id = intel.items.length;
        const item = {
          id,
          type,
          name:
            (node.alias && node.alias.value) ||
            (node.name && node.name.value) ||
            "",
          depth: intel.parentStack.length,
          order: id,
          children: [],
          withDirective: node.directives && node.directives.length > 0,
          isFragment: isFragmentNode(node),
          isFragmented: false,
          isFragmentedOn: false,
          hasAllPosibleFragmentTypes: false
        };

        const parent = getParentItem();
        if (parent) {
          parent.children.push(item.id);

          if (item.isFragment) {
            parent.isFragmented = true;
          }
        }

        intel.items.push(item);
        intel.parentStack.push(item);
      }
    },

    leave(node) {
      debug.log(`leave ${node.kind}`);

      if (isItemNode(node)) {
        const item = intel.parentStack.pop();

        if (item && item.isFragmented) {
          const namedType = getNamedType(item.type);
          const possibleFragmentTypes = schema.getPossibleTypes(namedType);
          const children = item.children.map(findByIdIn(intel.items));
          const fragments = children.filter(item => item.isFragment);
          const nonFragments = children.filter(item => !item.isFragment);
          const includedFragmentTypes = fragments
            .map(item => getNamedType(item.type))
            .reduce(getAllIncludedTypes(schema), []);

          const hasAllPosibleTypes = possibleFragmentTypes.every(type =>
            includedFragmentTypes.includes(type)
          );

          if (nonFragments.length === 0) {
            item.hasAllPosibleFragmentTypes = hasAllPosibleTypes;
          } else {
            const fragmentedItem: QueryIntelOutputItem = {
              id: intel.items.length,
              type: new GraphQLNonNull(namedType),
              name: "on",
              depth: item.depth + 0.5,
              order: getMaxOrder(nonFragments) + 0.5,
              children: fragments.map(getId),
              withDirective: false,
              isFragment: false,
              isFragmented: true,
              isFragmentedOn: true,
              hasAllPosibleFragmentTypes: hasAllPosibleTypes
            };

            intel.items.push(fragmentedItem);

            item.isFragmented = false;
            item.children = nonFragments.map(getId);
            item.children.push(fragmentedItem.id);
          }
        }
      }

      debug.addLogIndent(-1);
    }
  };
};

const getAllIncludedTypes = (schema: GraphQLSchema) => {
  const getAllTypes = (
    types: GraphQLNamedType[],
    type: GraphQLNamedType
  ): GraphQLNamedType[] =>
    types.concat(
      type,
      ...(schema.getPossibleTypes(type) || []).reduce(getAllTypes, [])
    );
  return getAllTypes;
};
