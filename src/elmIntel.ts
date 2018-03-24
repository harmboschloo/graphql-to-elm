import * as path from "path";
import {
  FinalOptions,
  TypeEncoders,
  TypeEncoder,
  TypeDecoders,
  TypeDecoder
} from "./options";
import {
  cachedValue,
  firstToUpperCase,
  firstToLowerCase,
  assertOk
} from "./utils";
import {
  QueryIntel,
  QueryOperation,
  QueryOperationType,
  QueryFragment,
  QueryInput,
  QueryInputField,
  QueryOutputField,
  QueryObjectInput,
  QueryObjectOutput,
  QueryObjectFragmentOutput,
  QueryNonFragmentOutput,
  QueryCompositeNonFragmentOutput,
  QueryFragmentedOutput,
  QueryFragmentedOnOutput,
  QueryFragmentedFragmentOutput,
  QueryFragmentOutput
} from "./queryIntel";

export interface ElmIntel {
  dest: string;
  module: string;
  operations: ElmOperation[];
  fragments: ElmFragment[];
}

export interface ElmScope {
  names: string[];
  typesBySignature: { [signature: string]: string };
  fragmentsByName: { [name: string]: string };
  encodersByType: { [type: string]: string };
  decodersByType: { [type: string]: string };
}

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

  const scope: ElmScope = {
    names: getReservedNames(),
    typesBySignature: {},
    fragmentsByName: {},
    encodersByType: {},
    decodersByType: {}
  };

  const operations = queryIntel.operations.map(operation =>
    getOperation(operation, scope, options)
  );

  const fragments = getFragments(queryIntel.fragments, scope, options);

  fixFragmentNames(operations, scope);

  const intel: ElmIntel = {
    dest,
    module,
    operations,
    fragments
  };

  // console.log("elm scope", JSON.stringify(scope, null, "  "));
  // console.log("elm intel", JSON.stringify(intel, null, "  "));

  return intel;
};

const getReservedNames = () => [...reservedNames];

const reservedNames = ["Int", "Float", "Bool", "String", "List"];

//
// OPERATIONS
//

export type ElmOperation = ElmQueryOperation | ElmNamedOperation;

export interface ElmQueryOperation {
  type: ElmOperationType;
  kind: "query";
  name: string;
  query: string;
  fragments: string[];
  variables: ElmRecordEncoder | undefined;
  data: ElmDecoder;
  errors: TypeDecoder;
}

export interface ElmNamedOperation {
  type: ElmOperationType;
  kind: "named";
  name: string;
  gqlName: string;
  variables: ElmRecordEncoder | undefined;
  data: ElmDecoder;
  errors: TypeDecoder;
}

export type ElmOperationType = "Query" | "Mutation" | "Subscription";

const getOperation = (
  queryOperation: QueryOperation,
  scope: ElmScope,
  options: FinalOptions
): ElmOperation => {
  const type = getOperationType(queryOperation.type);

  const name = newOperationName(queryOperation.name, scope);

  const variables: ElmRecordEncoder | undefined = queryOperation.inputs
    ? getRecordEncoder(queryOperation.inputs, scope, options)
    : undefined;

  const data: ElmDecoder = getCompositeDecoder(
    queryOperation.outputs,
    scope,
    options
  );

  const errors: TypeDecoder = options.errorsDecoder;

  switch (options.operationType) {
    case "query":
      return {
        type: getOperationType(queryOperation.type),
        kind: "query",
        name,
        query: queryOperation.query,
        fragments: queryOperation.fragmentNames,
        variables,
        data,
        errors
      };
    case "named":
      return {
        type: getOperationType(queryOperation.type),
        kind: "named",
        name,
        gqlName: queryOperation.name,
        variables,
        data,
        errors
      };
  }
};

const getOperationType = (type: QueryOperationType): ElmOperationType => {
  switch (type) {
    case "query":
      return "Query";
    case "mutation":
      return "Mutation";
    case "subscription":
      return "Subscription";
  }
};

const newOperationName = (name: string, scope: ElmScope): string =>
  getUnusedName(`${validVariableName(name)}`, scope.names);

const fixFragmentNames = (
  operations: ElmOperation[],
  scope: ElmScope
): void => {
  operations.forEach(operation => {
    if (operation.kind === "query") {
      operation.fragments = operation.fragments.map(name =>
        assertOk(scope.fragmentsByName[name])
      );
    }
  });
};

//
// FRAGMENTS
//

export interface ElmFragment {
  name: String;
  query: string;
}

const getFragments = (
  fragments: QueryFragment[],
  scope: ElmScope,
  options: FinalOptions
): ElmFragment[] => {
  switch (options.operationType) {
    case "query":
      return fragments.map(fragment => getFragment(fragment, scope));
    case "named":
      return [];
  }
};

const getFragment = (
  queryFragment: QueryFragment,
  scope: ElmScope
): ElmFragment => {
  const name = getUnusedName(
    validVariableName(queryFragment.name),
    scope.names
  );
  scope.fragmentsByName[queryFragment.name] = name;
  return {
    name,
    query: queryFragment.query
  };
};

//
// ENCODERS
//

export type ElmEncoder = ElmRecordEncoder | ElmValueEncoder;

export interface ElmRecordEncoder {
  kind: "record-encoder";
  type: string;
  encoder: string;
  fields: ElmEncoderField[];
}

export interface ElmEncoderField {
  jsonName: string;
  name: string;
  value: ElmEncoder;
  valueWrapper: false | "optional";
  valueListItemWrapper: false | "non-null" | "optional";
}

export interface ElmValueEncoder {
  kind: "value-encoder";
  type: string;
  encoder: string;
}

const getEncoder = (
  input: QueryInput,
  scope: ElmScope,
  options: FinalOptions
): ElmEncoder => {
  switch (input.kind) {
    case "object":
      return getRecordEncoder(input, scope, options);

    case "scalar": {
      const scalarEncoder: TypeEncoder = assertOk(
        options.scalarEncoders[input.typeName],
        `No encoder defined for scalar type: ${
          input.typeName
        }. Please add one to options.scalarEncoders`
      );

      return {
        ...scalarEncoder,
        kind: "value-encoder"
      };
    }

    case "enum": {
      const enumEncoder: TypeEncoder = assertOk(
        options.enumEncoders[input.typeName],
        `No encoder defined for enum type: ${
          input.typeName
        }. Please add one to options.enumEncoders`
      );

      return {
        ...enumEncoder,
        kind: "value-encoder"
      };
    }
  }
};

const getRecordEncoder = (
  input: QueryObjectInput,
  scope: ElmScope,
  options: FinalOptions
): ElmRecordEncoder => {
  const usedFieldNames = [];
  const fields: ElmEncoderField[] = input.fields.map(
    (field: QueryInputField): ElmEncoderField => ({
      jsonName: field.name,
      name: getUnusedName(validFieldName(field.name), usedFieldNames),
      value: getEncoder(field.value, scope, options),
      valueWrapper: field.valueWrapper,
      valueListItemWrapper: field.valueListItemWrapper
    })
  );
  const type = getRecordType(input, fields, scope);

  return {
    kind: "record-encoder",
    type,
    encoder: getEncoderName(type, scope),
    fields
  };
};

const getEncoderName = (type: string, scope: ElmScope): string =>
  cachedValue(type, scope.encodersByType, () =>
    getUnusedName(`encode${validNameUpper(type)}`, scope.names)
  );

//
// Decoders
//

export type ElmDecoder =
  | ElmValueDecoder
  | ElmConstantDecoder
  | ElmRecordDecoder
  | ElmUnionDecoder
  | ElmUnionOnDecoder
  | ElmEmptyDecoder;

export interface ElmValueDecoder {
  kind: "value-decoder";
  type: string;
  decoder: string;
}

export interface ElmConstantDecoder {
  kind: "constant-decoder";
  type: string;
  value: string;
  decoder: string;
}

export interface ElmRecordDecoder {
  kind: "record-decoder";
  type: string;
  decoder: string;
  fields: ElmDecoderField[];
}

export interface ElmDecoderField {
  jsonName: string;
  name: string;
  value: ElmDecoder;
  valueWrapper: false | "nullable" | "optional" | "non-null-optional";
  valueListItemWrapper: false | "non-null" | "nullable";
}

export interface ElmUnionDecoder {
  kind: "union-decoder";
  type: string;
  decoder: string;
  constructors: ElmUnionConstructor[];
}

export interface ElmUnionOnDecoder {
  kind: "union-on-decoder";
  type: string;
  decoder: string;
  constructors: ElmUnionConstructor[];
}

export interface ElmEmptyDecoder {
  kind: "empty-decoder";
  type: string;
  decoder: string;
}

export interface ElmUnionConstructor {
  name: string;
  decoder: ElmUnionConstructorDecoder;
}

export type ElmUnionConstructorDecoder =
  | ElmRecordDecoder
  | ElmUnionDecoder
  | ElmEmptyDecoder;

const getCompositeDecoder = (
  output: QueryCompositeNonFragmentOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmDecoder => {
  switch (output.kind) {
    case "object":
      return getRecordDecoder(output, scope, options);

    case "fragmented":
      return getUnionDecoder(output, scope, options);

    case "fragmented-on":
      return getUnionOnDecoder(output, scope, options);
  }
};

const getDecoder = (
  parentOutput: QueryObjectOutput | QueryObjectFragmentOutput,
  output: QueryNonFragmentOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmDecoder => {
  switch (output.kind) {
    case "object":
    case "fragmented":
    case "fragmented-on":
      return getCompositeDecoder(output, scope, options);

    case "typename":
      return {
        kind: "constant-decoder",
        type: output.typeName,
        value: `"${parentOutput.typeName}"`,
        decoder: "Json.Decode.string"
      };

    case "scalar": {
      const scalarDecoder: TypeDecoder = assertOk(
        options.scalarDecoders[output.typeName],
        `No decoder defined for scalar type: ${
          output.typeName
        }. Please add one to options.scalarDecoders`
      );

      return {
        ...scalarDecoder,
        kind: "value-decoder"
      };
    }

    case "enum": {
      const enumDecoder: TypeDecoder = assertOk(
        options.enumDecoders[output.typeName],
        `No decoder defined for enum type: ${
          output.typeName
        }. Please add one to options.enumDecoders`
      );

      return {
        ...enumDecoder,
        kind: "value-decoder"
      };
    }
  }
};

const getRecordDecoder = (
  output: QueryObjectOutput | QueryObjectFragmentOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmRecordDecoder => {
  const usedFieldNames = [];
  const fields: ElmDecoderField[] = output.fields.map(
    (field: QueryOutputField): ElmDecoderField => ({
      jsonName: field.name,
      name: getUnusedName(validFieldName(field.name), usedFieldNames),
      value: getDecoder(output, field.value, scope, options),
      valueWrapper: field.valueWrapper,
      valueListItemWrapper: field.valueListItemWrapper
    })
  );
  const type = getRecordType(output, fields, scope);

  return {
    kind: "record-decoder",
    type,
    decoder: getDecoderName(type, scope),
    fields
  };
};

const getUnionDecoder = (
  output: QueryFragmentedOutput | QueryFragmentedFragmentOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmUnionDecoder => {
  const decoders = getUnionConstructorDecoders(output, scope, options);
  const type = getUnionType(output, decoders, scope);
  const constructors = getUnionConstructors(type, decoders, scope);

  return {
    kind: "union-decoder",
    type,
    decoder: getDecoderName(type, scope),
    constructors
  };
};

const getUnionOnDecoder = (
  output: QueryFragmentedOnOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmUnionOnDecoder => {
  const decoders = getUnionConstructorDecoders(output, scope, options);
  const type = getUnionType(output, decoders, scope);
  const constructors = getUnionConstructors(type, decoders, scope);

  return {
    kind: "union-on-decoder",
    type,
    decoder: getDecoderName(type, scope),
    constructors
  };
};

const getUnionConstructorDecoders = (
  output:
    | QueryFragmentedOutput
    | QueryFragmentedFragmentOutput
    | QueryFragmentedOnOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmUnionConstructorDecoder[] =>
  checkUnionConstructorDecodeSignatures(
    output.fragments.map(fragment =>
      getUnionConstructorDecoder(fragment, scope, options)
    )
  );

const getUnionConstructorDecoder = (
  fragment: QueryFragmentOutput,
  scope: ElmScope,
  options: FinalOptions
): ElmUnionConstructorDecoder => {
  switch (fragment.kind) {
    case "object-fragment":
      return getRecordDecoder(fragment, scope, options);

    case "fragmented-fragment":
      return getUnionDecoder(fragment, scope, options);

    case "empty-fragment":
      return {
        kind: "empty-decoder",
        type: `Other${validNameUpper(fragment.typeName)}`,
        decoder: "GraphqlToElm.Helpers.Decode.emptyObject"
      };

    case "other-fragment": {
      return {
        kind: "empty-decoder",
        type: `Other${validNameUpper(fragment.typeName)}`,
        decoder: "Json.Decode.succeed"
      };
    }
  }
};

const checkUnionConstructorDecodeSignatures = (
  decoders: ElmUnionConstructorDecoder[]
): ElmUnionConstructorDecoder[] => {
  const signatures = decoders.map(getDecodeSignature);

  signatures.forEach((signature, index) => {
    if (signatures.indexOf(signature) !== index) {
      throw Error(
        `multiple union constructors with the same decode signature: ${signature}`
      );
    }
  });

  return decoders;
};

const getDecodeSignature = (decoder: ElmDecoder): string => {
  switch (decoder.kind) {
    case "constant-decoder":
      return `${decoder.type} ${decoder.value}`;

    case "value-decoder":
      return decoder.type;

    case "record-decoder":
      return decoder.fields
        .map(
          field =>
            `${field.jsonName} : ${wrapList(
              field.valueListItemWrapper,
              getDecodeSignature(field.value)
            )}`
        )
        .sort()
        .join(", ");

    case "union-decoder":
    case "union-on-decoder":
      return `${decoder.type} : ${decoder.constructors
        .map(constructor => getDecodeSignature(constructor.decoder))
        .sort()
        .join(" | ")}`;

    case "empty-decoder":
      return "{}";
  }
};

const wrapList = (isList: false | string, signature: string): string =>
  isList !== false ? `[${signature}]` : signature;

const getUnionType = (
  queryItem: { typeName: string },
  decoders: ElmUnionConstructorDecoder[],
  scope: ElmScope
): string =>
  cachedValue(
    getUnionSignature(queryItem, decoders),
    scope.typesBySignature,
    () => getUnusedName(validTypeName(queryItem.typeName), scope.names)
  );

const getUnionSignature = (
  queryItem: { typeName: string },
  decoders: ElmUnionConstructorDecoder[]
): string =>
  `${queryItem.typeName}: ${decoders.map(decoder => decoder.type).join(" | ")}`;

const getUnionConstructors = (
  unionType: string,
  decoders: ElmUnionConstructorDecoder[],
  scope: ElmScope
): ElmUnionConstructor[] =>
  decoders.map(decoder => ({
    name: getUnionConstructorName(unionType, decoder.type, scope),
    decoder
  }));

const getUnionConstructorName = (
  unionType: string,
  constructorType: string,
  scope: ElmScope
): string =>
  cachedValue(`${unionType} On${constructorType}`, scope.typesBySignature, () =>
    getUnusedName(
      validTypeConstructorName(`On${validNameUpper(constructorType)}`),
      scope.names
    )
  );

const getDecoderName = (type: string, scope: ElmScope): string =>
  cachedValue(type, scope.decodersByType, () =>
    getUnusedName(`${validVariableName(type)}Decoder`, scope.names)
  );

//
// RECORDS
//

export type ElmRecordField = ElmEncoderField | ElmDecoderField;

const getRecordType = (
  queryItem: { typeName: string },
  fields: ElmRecordField[],
  scope: ElmScope
): string =>
  cachedValue(
    getRecordSignature(queryItem, fields),
    scope.typesBySignature,
    () => getUnusedName(validTypeName(queryItem.typeName), scope.names)
  );

const getRecordSignature = (
  queryItem: { typeName: string },
  fields: ElmRecordField[]
): string => `${queryItem.typeName}: ${getRecordFieldsSignature(fields)}`;

const getRecordFieldsSignature = (fields: ElmRecordField[]): string =>
  fields
    .map(field => `${field.name} : ${wrappedTypeSignature(field)}`)
    .sort()
    .join(", ");

const wrappedTypeSignature = (field: ElmRecordField): string => {
  let signature = field.value.type;

  if (field.valueListItemWrapper) {
    signature = `[${field.valueListItemWrapper} ${signature}]`;
  }

  if (field.valueWrapper) {
    signature = `${field.valueWrapper} ${signature}`;
  }

  return signature;
};

//
//
//

const getUnusedName = (name: string, usedNames: string[]): string => {
  name = validWord(name);

  if (!usedNames.includes(name)) {
    usedNames.push(name);
    return name;
  } else {
    let count = 2;
    while (usedNames.includes(name + count)) {
      count++;
    }
    const name2 = name + count;
    usedNames.push(name2);
    return name2;
  }
};

export const validModuleName = (name: string): string => validNameUpper(name);

const validTypeName = (name: string): string => validNameUpper(name);

const validTypeConstructorName = (name: string): string => validNameUpper(name);

const validVariableName = (name: string): string => validNameLower(name);

const validFieldName = (name: string): string => validNameLower(name);

const validNameLower = (name: string): string =>
  validWord(firstToLowerCase(validNameUpper(name)));

const validNameUpper = (name: string): string =>
  name
    .split(/[^A-Za-z0-9_]/g)
    .filter(x => !!x)
    .map(firstToUpperCase)
    .join("")
    .replace(/^_+/, "");

const validWord = keyword =>
  elmKeywords.includes(keyword) ? `${keyword}_` : keyword;

const elmKeywords = [
  "as",
  "case",
  "else",
  "exposing",
  "if",
  "import",
  "in",
  "let",
  "module",
  "of",
  "port",
  "then",
  "type",
  "where"
  // "alias",
  // "command",
  // "effect",
  // "false",
  // "infix",
  // "left",
  // "non",
  // "null",
  // "right",
  // "subscription",
  // "true",
];
