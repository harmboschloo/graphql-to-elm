import {
  GraphQLSchema,
  GraphQLType,
  GraphQLNonNull,
  GraphQLList,
  GraphQLScalarType,
  GraphQLEnumType,
  GraphQLNamedType,
  GraphQLCompositeType,
  GraphQLObjectType,
  GraphQLInputType,
  GraphQLInputObjectType,
  GraphQLInputFieldMap,
  GraphQLInputField,
  DocumentNode,
  OperationDefinitionNode,
  FragmentDefinitionNode,
  FragmentSpreadNode,
  InlineFragmentNode,
  FieldNode,
  VariableDefinitionNode,
  Location,
  TypeInfo,
  Kind,
  isCompositeType,
  assertCompositeType,
  isAbstractType,
  assertType,
  assertInputType,
  getNamedType,
  getNullableType,
  typeFromAST,
  parse,
  visit,
  visitWithTypeInfo,
  validate
} from "graphql";
import { FinalOptions } from "../options";
import {
  readFile,
  removeIndents,
  assertOk,
  addOnce,
  firstToUpperCase
} from "../utils";

export interface QueryIntel {
  src: string;
  query: string;
  fragments: QueryFragment[];
  operations: QueryOperation[];
}

export interface QueryFragment {
  name: string;
  query: string;
}

interface OperationNodeInfo {
  query: string;
  fragmentNames: string[];
  node: OperationDefinitionNode;
}

export interface QueryOperation {
  type: QueryOperationType;
  name: string | undefined;
  query: string;
  fragmentNames: string[];
  inputs: QueryObjectInput | undefined;
  outputs: QueryRootOutput;
}

export type QueryOperationType = "query" | "mutation" | "subscription";

export type QueryRootOutput = QueryObjectOutput | QueryFragmentedOutput;

export const readQueryIntel = (
  src: string,
  schema: GraphQLSchema,
  options: FinalOptions
): Promise<QueryIntel> => {
  return readFile(src)
    .then(query => {
      options.log(`processing query ${src}`);
      query = query.trim().replace(/\r\n/g, "\n");
      return {
        ...getQueryIntel(query, schema),
        src
      };
    })
    .catch((error: Error) => {
      throw new Error(`processing query ${src}\n${error.toString()}`);
    });
};

export const getQueryIntel = (
  query: string,
  schema: GraphQLSchema
): QueryIntel => {
  const { operationsInfo, fragments } = getOperationsInfo(query, schema);

  const operations: QueryOperation[] = operationsInfo.map(getOperation(schema));

  const intel: QueryIntel = {
    src: "",
    query,
    fragments,
    operations
  };

  // console.log("query intel", JSON.stringify(intel, null, "  "));

  return intel;
};

const getOperationsInfo = (
  query: string,
  schema: GraphQLSchema
): {
  operationsInfo: OperationNodeInfo[];
  fragments: QueryFragment[];
} => {
  const queryDocument = parseAndValidate(query, schema);

  const fragmentNodes: { [name: string]: FragmentDefinitionNode } = {};
  const fragments: QueryFragment[] = [];
  visit(queryDocument, {
    FragmentDefinition(node: FragmentDefinitionNode) {
      const location = assertLocation(node.loc);
      fragmentNodes[node.name.value] = node;
      fragments.push({
        name: node.name.value,
        query: removeIndents(query.substring(location.start, location.end))
      });
    }
  });

  const operationsInfo: OperationNodeInfo[] = [];
  visit(queryDocument, {
    OperationDefinition(node: OperationDefinitionNode) {
      const location = assertLocation(node.loc);
      operationsInfo.push({
        query: removeIndents(query.substring(location.start, location.end)),
        node: node,
        fragmentNames: []
      });
    }
  });

  operationsInfo.forEach((info: OperationNodeInfo) => {
    info.node = visit(info.node, {
      FragmentSpread(node: FragmentSpreadNode): InlineFragmentNode {
        addOnce(node.name.value, info.fragmentNames);
        const fragmentNode = fragmentNodes[node.name.value];
        return {
          kind: Kind.INLINE_FRAGMENT,
          typeCondition: fragmentNode.typeCondition,
          directives: fragmentNode.directives,
          selectionSet: fragmentNode.selectionSet,
          loc: fragmentNode.loc
        };
      }
    });
  });

  const findFragmentByName = (name: string): QueryFragment =>
    assertOk(fragments.find(fragment => fragment.name === name));

  operationsInfo.forEach(info => {
    const fragmentQueries: string[] = info.fragmentNames
      .map(findFragmentByName)
      .map(fragment => fragment.query);
    const query = `${info.query}${fragmentQueries.join("")}`;
    parseAndValidate(query, schema);
  });

  return { operationsInfo, fragments };
};

const getOperation = (schema: GraphQLSchema) => (
  info: OperationNodeInfo
): QueryOperation => ({
  type: info.node.operation,
  name: info.node.name ? info.node.name.value : undefined,
  query: info.query,
  fragmentNames: info.fragmentNames,
  inputs: getInputs(info.node, schema),
  outputs: getOutputs(info.node, schema)
});

const assertLocation = (location: Location | undefined): Location =>
  assertOk(location, "no query location");

const parseAndValidate = (query: string, schema: GraphQLSchema) => {
  const document: DocumentNode = parse(query);

  const errors = validate(schema, document);
  if (errors.length > 0) {
    throw errors[0];
  }

  return document;
};

//
// INPUTS
//

export type QueryInput = QueryObjectInput | QueryScalarInput | QueryEnumInput;

export interface QueryObjectInput {
  kind: "object";
  typeName: string;
  fields: QueryInputField[];
}

export interface QueryInputField {
  name: string;
  value: QueryInput;
  valueWrapper: false | "optional";
  valueListItemWrapper: false | "non-null" | "optional";
}

export interface QueryScalarInput {
  kind: "scalar";
  typeName: string;
}

export interface QueryEnumInput {
  kind: "enum";
  typeName: string;
}

const getInputs = (
  node: OperationDefinitionNode,
  schema: GraphQLSchema
): QueryObjectInput | undefined =>
  node.variableDefinitions && node.variableDefinitions.length > 0
    ? {
        typeName: `${node.name ? node.name.value : ""}Variables`,
        kind: "object",
        fields: node.variableDefinitions.map((node: VariableDefinitionNode) =>
          nodeToInputField(node, schema)
        )
      }
    : undefined;

const nodeToInputField = (
  node: VariableDefinitionNode,
  schema: GraphQLSchema
): QueryInputField =>
  mapInputField(
    {
      name: node.variable.name.value,
      type: getInputType(node, schema),
      extensions: null
    },
    schema
  );

const mapInputField = (
  field: GraphQLInputField,
  schema: GraphQLSchema
): QueryInputField => {
  const namedType: GraphQLNamedType = getNamedType(field.type);
  const nullableType = getNullableType(field.type);
  const typeName = namedType.name;

  let value: QueryInput | undefined = undefined;

  if (namedType instanceof GraphQLInputObjectType) {
    const fields: GraphQLInputFieldMap = namedType.getFields();
    value = {
      kind: "object",
      typeName,
      fields: Object.keys(fields).map(key => mapInputField(fields[key], schema))
    };
  } else if (namedType instanceof GraphQLScalarType) {
    value = {
      kind: "scalar",
      typeName
    };
  } else if (namedType instanceof GraphQLEnumType) {
    value = {
      kind: "enum",
      typeName
    };
  }

  return {
    name: field.name,
    value: assertOk(value, `unhandled query input of type ${field.type}`),
    valueWrapper: field.type instanceof GraphQLNonNull ? false : "optional",
    valueListItemWrapper:
      nullableType instanceof GraphQLList
        ? nullableType.ofType instanceof GraphQLNonNull
          ? "non-null"
          : "optional"
        : false
  };
};

const getInputType = (
  node: VariableDefinitionNode,
  schema: GraphQLSchema
): GraphQLInputType =>
  assertInputType(
    typeFromAST(
      schema,
      // @ts-ignore
      node.type
    )
  );

//
// OUTPUTS
//

export type QueryOutput = QueryNonFragmentOutput | QueryFragmentOutput;

export type QueryNonFragmentOutput =
  | QueryCompositeNonFragmentOutput
  | QueryScalarOutput
  | QueryEnumOutput
  | QueryTypenameOutput;

export type QueryCompositeNonFragmentOutput =
  | QueryObjectOutput
  | QueryFragmentedOutput
  | QueryFragmentedOnOutput;

export interface QueryObjectOutput {
  kind: "object";
  typeName: string;
  fields: QueryOutputField[];
}

export interface QueryOutputField {
  name: string;
  value: QueryNonFragmentOutput;
  valueWrapper: false | "nullable" | "optional" | "non-null-optional";
  valueListItemWrapper: false | "non-null" | "nullable";
}

export interface QueryFragmentedOutput {
  kind: "fragmented";
  typeName: string;
  fragments: QueryFragmentOutput[];
}

export interface QueryFragmentedOnOutput {
  kind: "fragmented-on";
  typeName: string;
  fragments: QueryFragmentOutput[];
}

export interface QueryScalarOutput {
  kind: "scalar";
  typeName: string;
}

export interface QueryEnumOutput {
  kind: "enum";
  typeName: string;
}

export interface QueryTypenameOutput {
  kind: "typename";
  typeName: string;
}

export type QueryFragmentOutput =
  | QueryCompositeFragmentOutput
  | QueryEmptyFragmentOutput
  | QueryOtherFragmentOutput;

export type QueryCompositeFragmentOutput =
  | QueryObjectFragmentOutput
  | QueryFragmentedFragmentOutput;

export interface QueryObjectFragmentOutput {
  kind: "object-fragment";
  type: GraphQLCompositeType;
  typeName: string;
  fields: QueryOutputField[];
}

export interface QueryFragmentedFragmentOutput {
  kind: "fragmented-fragment";
  type: GraphQLCompositeType;
  typeName: string;
  fragments: QueryFragmentOutput[];
}

export interface QueryEmptyFragmentOutput {
  kind: "empty-fragment";
  typeName: string;
}

export interface QueryOtherFragmentOutput {
  kind: "other-fragment";
  typeName: string;
}

type OutputNode = OperationDefinitionNode | FieldNode | InlineFragmentNode;

export const isFragmentOutput = (
  output: QueryOutput
): output is QueryFragmentOutput => {
  switch (output.kind) {
    case "object":
    case "fragmented":
    case "fragmented-on":
    case "scalar":
    case "enum":
    case "typename":
      return false;
    case "object-fragment":
    case "fragmented-fragment":
    case "empty-fragment":
    case "other-fragment":
      return true;
  }
};

export const isNonFragmentOutput = (
  output: QueryOutput
): output is QueryNonFragmentOutput => !isFragmentOutput(output);

export const isTypenameOutput = (
  output: QueryOutput
): output is QueryTypenameOutput => output.kind === "typename";

export const isObjectFragmentOutput = (
  output: QueryOutput
): output is QueryObjectFragmentOutput => output.kind === "object-fragment";

export const assertNonFragmentOutput = (
  output: QueryOutput
): QueryNonFragmentOutput => {
  if (!isNonFragmentOutput(output)) {
    throw Error("not a QueryNonFragmentOutput");
  }
  return output;
};

export const assertObjectFragmentOutput = (
  output: QueryOutput
): QueryObjectFragmentOutput => {
  if (!isObjectFragmentOutput(output)) {
    throw Error("not a QueryObjectFragmentOutput");
  }
  return output;
};

const getOutputs = (
  node: OperationDefinitionNode,
  schema: GraphQLSchema
): QueryRootOutput => {
  let rootOutput: QueryRootOutput | undefined = undefined;

  type NodeInfo = {
    fields: QueryOutputField[];
    fragments: QueryCompositeFragmentOutput[];
  };

  const nodeInfoStack: NodeInfo[] = [];

  const getNodeInfo = () => nodeInfoStack[nodeInfoStack.length - 1];

  const addFieldToParent = (
    node: OutputNode,
    name: string,
    type: GraphQLType,
    output: QueryNonFragmentOutput
  ) => {
    const parentNodeInfo = getNodeInfo();

    if (!parentNodeInfo) {
      throw Error(`can not add output field to parent`);
    }

    const nullableType = getNullableType(type);
    const hasDirective = node.directives ? node.directives.length > 0 : false;

    const field: QueryOutputField = {
      name,
      value: output,
      valueWrapper:
        type instanceof GraphQLNonNull
          ? hasDirective
            ? "non-null-optional"
            : false
          : hasDirective
          ? "optional"
          : "nullable",
      valueListItemWrapper:
        nullableType instanceof GraphQLList
          ? nullableType.ofType instanceof GraphQLNonNull
            ? "non-null"
            : "nullable"
          : false
    };

    parentNodeInfo.fields.push(field);
  };

  const addFragmentToParent = (output: QueryCompositeFragmentOutput) => {
    const parentNodeInfo = getNodeInfo();

    if (!parentNodeInfo) {
      throw Error(`can not add output fragment to parent`);
    }

    parentNodeInfo.fragments.push(output);
  };

  const typeInfo = new TypeInfo(schema);

  const pushNodeInfo = () => {
    nodeInfoStack.push({
      fields: [],
      fragments: []
    });
  };

  const popNodeInfo = (): NodeInfo => assertOk(nodeInfoStack.pop());

  const visitor = {
    enter: {
      OperationDefinition() {
        pushNodeInfo();
      },
      Field() {
        pushNodeInfo();
      },
      InlineFragment() {
        pushNodeInfo();
      }
    },
    leave: {
      OperationDefinition(node: OperationDefinitionNode) {
        const nodeInfo: NodeInfo = popNodeInfo();
        const name: string = "";
        const type: GraphQLCompositeType = assertCompositeType(
          typeInfo.getType()
        );
        rootOutput = getCompositeOutput(
          name,
          type,
          nodeInfo.fields,
          nodeInfo.fragments,
          schema
        );
        rootOutput.typeName = `${
          node.name ? node.name.value : ""
        }${firstToUpperCase(rootOutput.typeName)}`;
      },
      Field(node: FieldNode) {
        const nodeInfo: NodeInfo = popNodeInfo();
        const name: string = node.alias ? node.alias.value : node.name.value;
        const type: GraphQLType = assertType(typeInfo.getType());
        const output: QueryNonFragmentOutput = getOutput(
          name,
          type,
          nodeInfo.fields,
          nodeInfo.fragments,
          schema
        );
        addFieldToParent(node, name, type, output);
      },
      InlineFragment() {
        const nodeInfo: NodeInfo = popNodeInfo();
        const type: GraphQLCompositeType = assertCompositeType(
          typeInfo.getType()
        );
        const typeName: string = type.name;
        const result = getFieldsOrFragments(
          schema,
          type,
          nodeInfo.fields,
          nodeInfo.fragments
        );
        if ("fields" in result) {
          addFragmentToParent({
            kind: "object-fragment",
            type,
            typeName,
            fields: result.fields
          });
        } else {
          addFragmentToParent({
            kind: "fragmented-fragment",
            type,
            typeName,
            fragments: result.fragments
          });
        }
      }
    }
  };

  visit(node, visitWithTypeInfo(typeInfo, visitor));

  return assertOk<QueryRootOutput>(rootOutput, "no root output");
};

const getOutput = (
  name: string,
  type: GraphQLType,
  fields: QueryOutputField[],
  fragments: QueryCompositeFragmentOutput[],
  schema: GraphQLSchema
): QueryNonFragmentOutput => {
  const namedType = getNamedType(type);
  const typeName = namedType.name;

  if (isCompositeType(namedType)) {
    return getCompositeOutput(name, namedType, fields, fragments, schema);
  } else if (namedType instanceof GraphQLScalarType) {
    if (name === "__typename") {
      return {
        typeName,
        kind: "typename"
      };
    } else {
      return {
        typeName,
        kind: "scalar"
      };
    }
  } else if (namedType instanceof GraphQLEnumType) {
    return {
      typeName,
      kind: "enum"
    };
  }

  throw Error(`unhandled query output of type ${type}`);
};

const getCompositeOutput = (
  name: string,
  type: GraphQLCompositeType,
  fields: QueryOutputField[],
  fragments: QueryCompositeFragmentOutput[],
  schema: GraphQLSchema
): QueryObjectOutput | QueryFragmentedOutput => {
  const typeName = type.name;
  const result = getFieldsOrFragments(schema, type, fields, fragments);

  if ("fields" in result) {
    return {
      kind: "object",
      typeName,
      fields: result.fields
    };
  } else {
    return {
      kind: "fragmented",
      typeName,
      fragments: result.fragments
    };
  }
};

const getFragment = (
  type: GraphQLCompositeType,
  fields: QueryOutputField[],
  fragments: QueryCompositeFragmentOutput[],
  schema: GraphQLSchema
): QueryCompositeFragmentOutput => {
  const namedType = getNamedType(type);
  const typeName = namedType.name;
  const result = getFieldsOrFragments(schema, type, fields, fragments);
  if ("fields" in result) {
    return {
      kind: "object-fragment",
      type,
      typeName,
      fields: result.fields
    };
  } else {
    return {
      kind: "fragmented-fragment",
      type,
      typeName,
      fragments: result.fragments
    };
  }
};

const getFieldsOrFragments = (
  schema: GraphQLSchema,
  type: GraphQLCompositeType,
  fields: QueryOutputField[],
  inFragments: QueryCompositeFragmentOutput[]
): { fields: QueryOutputField[] } | { fragments: QueryFragmentOutput[] } => {
  const typeName = type.name;

  const typenameFields: QueryOutputField[] = fields.filter(field =>
    isTypenameOutput(field.value)
  );

  const possibleFragmentTypes: ReadonlyArray<GraphQLObjectType> = isAbstractType(
    type
  )
    ? schema.getPossibleTypes(type)
    : [];

  if (typenameFields.length > 0) {
    if (possibleFragmentTypes.length > 0) {
      const fragmentTypeNames = getAllIncludedFragmentTypes(
        inFragments,
        schema
      ).map(type => type.name);

      const missingFragmentTypes = possibleFragmentTypes.filter(
        type => !fragmentTypeNames.includes(type.name)
      );

      missingFragmentTypes.forEach(type =>
        inFragments.push({
          kind: "object-fragment",
          type,
          typeName: type.name,
          fields: []
        })
      );
    }

    if (inFragments.length > 0) {
      fields = fields.filter(field => !typenameFields.includes(field));
      inFragments.forEach(fragment => {
        if (fragment.kind === "object-fragment") {
          fragment.fields.push(...typenameFields);
        }
      });
    }
  }

  const includedFragmentTypes: GraphQLNamedType[] = getAllIncludedFragmentTypes(
    inFragments,
    schema
  );

  const hasAllPossibleTypes: boolean = possibleFragmentTypes.every(type =>
    includedFragmentTypes.includes(type)
  );

  if (inFragments.length === 1 && hasAllPossibleTypes) {
    const fragment = inFragments[0];
    if (fragment.kind === "object-fragment") {
      fields = [...fields, ...fragment.fields];
      inFragments = [];
    }
  }

  let fragments: QueryFragmentOutput[] = inFragments;

  if (fields.length === 0 && fragments.length > 0) {
    if (!hasAllPossibleTypes) {
      fragments.push({
        kind: "empty-fragment",
        typeName
      });
    }
  }

  if (fields.length > 0 && fragments.length > 0) {
    if (!hasAllPossibleTypes) {
      fragments.push({
        kind: "other-fragment",
        typeName
      });
    }

    const onField: QueryOutputField = {
      name: "on",
      value: {
        kind: "fragmented-on",
        typeName: `On${typeName}`,
        fragments
      },
      valueWrapper: false,
      valueListItemWrapper: false
    };

    fields = [...fields, onField];
    fragments = [];
  }

  if (fields.length > 0 && fragments.length === 0) {
    return { fields };
  }

  if (fields.length === 0 && fragments.length > 0) {
    return { fragments };
  }

  throw Error("no fields or fragments");
};

const getAllIncludedFragmentTypes = (
  fragments: QueryCompositeFragmentOutput[],
  schema: GraphQLSchema
): GraphQLNamedType[] =>
  getAllIncludedTypes(
    fragments.map(fragment => fragment.type),
    schema
  );

const getAllIncludedTypes = (
  types: GraphQLCompositeType[],
  schema: GraphQLSchema
): GraphQLNamedType[] => {
  const helper = (
    collected: GraphQLNamedType[],
    type: GraphQLNamedType
  ): GraphQLNamedType[] =>
    isAbstractType(type)
      ? schema.getPossibleTypes(type).reduce(helper, [...collected, type])
      : [...collected, type];

  return types.reduce(helper, []);
};

// Convert Input types as compatible Output types

const inputValueListItemWrapperAsOutput = (
  inputWrapper: false | "non-null" | "optional"
): false | "non-null" | "nullable" => {
  switch (inputWrapper) {
    case "optional":
      return "nullable";
    case "non-null":
      return "non-null";
    case false:
      return false;
  }
};

const queryInputFieldAsOutput = (
  inputField: QueryInputField
): QueryOutputField => {
  switch (inputField.value.kind) {
    case "scalar":
    case "enum":
      return {
        name: inputField.name,
        value: queryInputAsOutput(inputField.value),
        valueWrapper: inputField.valueWrapper,
        valueListItemWrapper: inputValueListItemWrapperAsOutput(
          inputField.valueListItemWrapper
        )
      };
      break;

    case "object":
      return {
        name: inputField.name,
        value: queryInputAsOutput(inputField.value),
        valueWrapper: inputField.valueWrapper,
        valueListItemWrapper: inputValueListItemWrapperAsOutput(
          inputField.valueListItemWrapper
        )
      };
      break;
  }
};

const queryInputAsOutput = (input: QueryInput): QueryNonFragmentOutput => {
  switch (input.kind) {
    case "object":
      return queryObjectInputAsOutput(input);

    default:
      return {
        kind: input.kind,
        typeName: input.typeName
      };
  }
};

export const queryObjectInputAsOutput = (
  input: QueryObjectInput
): QueryCompositeNonFragmentOutput => {
  return {
    kind: "object",
    typeName: input.typeName,
    fields: input.fields.map(queryInputFieldAsOutput)
  };
};
