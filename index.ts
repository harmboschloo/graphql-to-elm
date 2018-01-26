import { readFileSync, writeFileSync } from "fs";
import {
  GraphQLSchema,
  buildSchema,
  validate,
  parse,
  visit,
  visitWithTypeInfo,
  TypeInfo,
  Kind,
  isCompositeType,
  isListType,
  isLeafType,
  isNullableType,
  instanceOf,
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

  writeFileSync(`${queryPath}.elm`, visitor.output(), "utf-8");
};

const queryVisitor = (typeInfo: TypeInfo) => {
  const intel: any[] = [];
  const parentRecordStack: any[] = [];
  const getParentRecord = () => {
    if (parentRecordStack.length > 0) {
      return parentRecordStack[parentRecordStack.length - 1];
    }
  };

  let indent = 0;
  let pad = "";

  return {
    output() {
      return "module ToDo\n\n" + JSON.stringify(intel, null, "\t");
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

      switch (node.kind) {
        case Kind.OPERATION_DEFINITION:
        case Kind.FIELD:
          const id = intel.length;
          const type = typeInfo.getType();
          const namedType = getNamedType(type);
          const nullableType = getNullableType(type);
          const nullable = isNullableType(type);
          const list = isListType(nullableType);
          const depth = parentRecordStack.length;
          const name = node.name && node.name.value;

          if (isCompositeType(namedType)) {
            const item = {
              id,
              type,
              namedType,
              nullableType,
              nullable,
              list,
              name,
              depth,
              children: []
            };
            intel.push(item);
            parentRecordStack.push(item);
          } else if (isLeafType(namedType)) {
            const item = {
              id,
              type,
              namedType,
              nullableType,
              nullable,
              list,
              name,
              depth,
              children: null
            };
            const parent = getParentRecord();
            if (parent) {
              parent.children.push(item.id);
            }
            intel.push(item);
          }

          break;
      }
    },
    leave(node) {
      console.log(pad, "leave", node.kind);

      const type = typeInfo.getType();
      const namedType = getNamedType(type);

      switch (node.kind) {
        case Kind.OPERATION_DEFINITION:
        case Kind.FIELD:
          const type = typeInfo.getType();
          const namedType = getNamedType(type);
          if (isCompositeType(namedType)) {
            parentRecordStack.pop();
          }
      }

      pad = pad.slice(0, -2);
    }
  };
};
