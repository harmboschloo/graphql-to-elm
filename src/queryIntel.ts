import {
  GraphQLSchema,
  GraphQLNonNull,
  GraphQLNamedType,
  GraphQLInputType,
  GraphQLInputObjectType,
  GraphQLOutputType,
  TypeInfo,
  Kind,
  isAbstractType,
  getNamedType,
  parse,
  visit,
  visitWithTypeInfo,
  validate
} from "graphql";
import { FinalOptions } from "./options";
import { readFile, findByIdIn, getId, getMaxOrder } from "./utils";
import * as debug from "./debug";

export interface QueryIntel {
  src: string;
  query: string;
  inputs: QueryInputItem[];
  outputs: QueryOutputItem[];
}

export type QueryItem = QueryInputItem | QueryOutputItem;

export interface QueryInputItem {
  id: number;
  name: string;
  depth: number;
  order: number;
  children: number[];
  type: GraphQLInputType;
}

export interface QueryOutputItem {
  id: number;
  name: string;
  depth: number;
  order: number;
  children: number[];
  type: GraphQLOutputType;
  withDirective: boolean;
  isFragment: boolean;
  isFragmented: boolean;
  isFragmentedOn: boolean;
  hasAllPosibleFragmentTypes: boolean;
  isValid: boolean; //FIXME
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
    inputs: [],
    outputs: []
  };

  const addInput = ({
    type,
    name,
    parent
  }: {
    type: GraphQLInputType;
    name: string;
    parent: QueryInputItem;
  }) => {
    const id = intel.inputs.length;
    const item = {
      id,
      type,
      name,
      depth: parent.depth + 1,
      order: id,
      children: [],
      isValid: true
    };

    intel.inputs.push(item);
    parent.children.push(item.id);

    const namedType = getNamedType(type);

    if (namedType instanceof GraphQLInputObjectType) {
      const fields = namedType.getFields();
      Object.keys(fields).forEach(fieldName =>
        addInput({
          type: fields[fieldName].type,
          name: fieldName,
          parent: item
        })
      );
    }
  };

  const isOutputItemNode = node =>
    node.kind === Kind.OPERATION_DEFINITION ||
    node.kind === Kind.FIELD ||
    isFragmentNode(node);

  const isFragmentNode = node => node.kind === Kind.INLINE_FRAGMENT;

  const parentStack: QueryOutputItem[] = [];
  const getParentItem = () => parentStack[parentStack.length - 1];

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
        if (intel.inputs.length === 0) {
          intel.inputs.push({
            id: 0,
            type: typeInfo.getInputType(),
            name: "",
            depth: 0,
            order: 0,
            children: []
          });
        }

        addInput({
          type: typeInfo.getInputType(),
          name: node.variable.name.value,
          parent: intel.inputs[0]
        });
      }

      if (isOutputItemNode(node)) {
        const type = typeInfo.getType();

        const id = intel.outputs.length;
        const item = {
          id,
          type,
          name:
            (node.alias && node.alias.value) ||
            (node.name && node.name.value) ||
            "",
          depth: parentStack.length,
          order: id,
          children: [],
          isValid: true,
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

        intel.outputs.push(item);
        parentStack.push(item);
      }
    },

    leave(node) {
      debug.log(`leave ${node.kind}`);

      if (isOutputItemNode(node)) {
        const item = parentStack.pop();

        if (item && item.isFragmented) {
          const namedType = getNamedType(item.type);
          const possibleFragmentTypes = isAbstractType(namedType)
            ? schema.getPossibleTypes(namedType)
            : [];
          const children = item.children.map(findByIdIn(intel.outputs));
          const fragments = children.filter(item => item.isFragment);
          let nonFragments = children.filter(item => !item.isFragment);
          const typenames = children.filter(item => item.name === "__typename");
          const includedFragmentTypes = fragments
            .map(item => getNamedType(item.type))
            .reduce(getAllIncludedTypes(schema), []);
          const hasAllPosibleTypes = possibleFragmentTypes.every(type =>
            includedFragmentTypes.includes(type)
          );

          if (typenames.length > 0) {
            typenames.forEach(item => (item.depth = item.depth + 1));
            const typenameIds = typenames.map(getId);
            item.children = item.children.filter(
              id => !typenameIds.includes(id)
            );
            fragments.forEach(item => item.children.push(...typenameIds));
            nonFragments = nonFragments.filter(
              item => !typenameIds.includes(item.id)
            );
          }

          if (hasAllPosibleTypes && fragments.length <= 1) {
            const fragment = fragments[0];
            if (fragment) {
              fragment.isValid = false;
            }
            const fragmentChildren = fragment ? fragment.children : [];
            item.children = [...nonFragments.map(getId), ...fragmentChildren];
            item.isFragmented = false;
          } else if (nonFragments.length === 0) {
            item.hasAllPosibleFragmentTypes = hasAllPosibleTypes;
          } else if (nonFragments.length > 0) {
            const fragmentedItem: QueryOutputItem = {
              id: intel.outputs.length,
              type: new GraphQLNonNull(namedType),
              name: "on",
              depth: item.depth + 0.5,
              order: getMaxOrder(nonFragments) + 0.5,
              children: fragments.map(getId),
              isValid: true,
              withDirective: false,
              isFragment: false,
              isFragmented: true,
              isFragmentedOn: true,
              hasAllPosibleFragmentTypes: hasAllPosibleTypes
            };

            intel.outputs.push(fragmentedItem);

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
      ...(isAbstractType(type) ? schema.getPossibleTypes(type) : []).reduce(
        getAllTypes,
        []
      )
    );
  return getAllTypes;
};
