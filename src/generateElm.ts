import {
  ElmIntel,
  ElmOperation,
  ElmQueryOperation,
  ElmFragment,
  ElmEncoder,
  ElmRecordEncoder,
  ElmValueEncoder,
  ElmDecoder,
  ElmValueDecoder,
  ElmConstantDecoder,
  ElmRecordDecoder,
  ElmUnionDecoder,
  ElmUnionOnDecoder,
  ElmEmptyDecoder,
  ElmUnionConstructor,
  ElmEncoderField,
  ElmDecoderField,
  ElmRecordField
} from "./elmIntel";
import { withParentheses, addOnce } from "./utils";

type TypeWrapper = false | "nullable" | "optional" | "non-null-optional";
type ListItemWrapper = false | "non-null" | "nullable" | "optional";

export const generateElm = (intel: ElmIntel): string => `module ${intel.module}
    exposing
        ( ${generateExports(intel)}
        )

${generateImports(intel)}


${generateOperations(intel)}${generateFragments(intel)}


${generateOperationResponses(intel)}


${generateEncodersAndDecoders(intel)}
`;

//
// EXPORTS
//

const generateExports = (intel: ElmIntel): string => {
  const types: string[] = [];
  const variables: string[] = [];

  const addType = type => addOnce(type, types);
  const addVariable = variable => addOnce(variable, variables);

  intel.operations.forEach(operation => {
    addType(operation.responseTypeName);
    addVariable(operation.name);

    if (operation.variables) {
      visitEncoders(operation.variables, {
        record: (encoder: ElmRecordEncoder) => {
          addType(encoder.type);
        },
        value: (encoder: ElmValueEncoder) => {}
      });
    }

    visitDecoders(operation.data, {
      value: (decoder: ElmValueDecoder) => {},
      constant: (decoder: ElmConstantDecoder) => {},
      record: (decoder: ElmRecordDecoder) => {
        addType(decoder.type);
      },
      union: (decoder: ElmUnionDecoder) => {
        addType(`${decoder.type}(..)`);
      },
      unionOn: (decoder: ElmUnionOnDecoder) => {
        addType(`${decoder.type}(..)`);
      },
      empty: (decoder: ElmEmptyDecoder) => {}
    });
  });

  return [...types, ...variables].join("\n        , ");
};

//
// IMPORTS
//

const generateImports = (intel: ElmIntel): string => {
  const imports = ["Json.Decode"];

  const addImport = module => addOnce(module, imports);

  const addImportOf = x => {
    const module = x && extractModule(x);
    if (module) {
      addImport(module);
    }
  };

  const addWrapperImports = ({
    valueWrapper,
    valueListItemWrapper
  }: {
    valueWrapper: TypeWrapper;
    valueListItemWrapper: ListItemWrapper;
  }) => {
    switch (valueWrapper) {
      case "optional":
        addImport("GraphQL.Optional");
        break;
      case "non-null-optional":
        addImport("GraphQL.Optional");
        break;
    }

    switch (valueListItemWrapper) {
      case "optional":
        addImport("GraphQL.Optional");
        break;
    }
  };

  intel.operations.forEach(operation => {
    addImport("GraphQL.Operation");
    addImport("GraphQL.Response");

    if (operation.variables) {
      visitEncoders(operation.variables, {
        record: (encoder: ElmRecordEncoder) => {
          encoder.fields.map(addWrapperImports);
        },
        value: (encoder: ElmValueEncoder) => {
          addImportOf(encoder.type);
          addImportOf(encoder.encoder);
        }
      });
    }

    visitDecoders(operation.data, {
      value: (decoder: ElmValueDecoder) => {
        addImportOf(decoder.type);
        addImportOf(decoder.decoder);
      },
      constant: (decoder: ElmConstantDecoder) => {
        addImportOf(decoder.decoder);
        addImport("GraphQL.Helpers.Decode");
      },
      record: (decoder: ElmRecordDecoder) => {
        decoder.fields.map(addWrapperImports);
        if (decoder.fields.length > 8) {
          addImport("GraphQL.Helpers.Decode");
        }
      },
      union: (decoder: ElmUnionDecoder) => {},
      unionOn: (decoder: ElmUnionOnDecoder) => {},
      empty: (decoder: ElmEmptyDecoder) => {
        addImportOf(decoder.decoder);
      }
    });

    addImportOf(operation.errors.type);
    addImportOf(operation.errors.decoder);
  });

  return imports
    .sort()
    .map(name => `import ${name}`)
    .join("\n");
};

const extractModule = (expression: string): string =>
  expression.substr(0, expression.lastIndexOf("."));

//
// OPERATIONS
//

const generateOperations = (intel: ElmIntel): string =>
  intel.operations.map(generateOperation).join("\n\n\n");

const generateOperation = (operation: ElmOperation): string => {
  const variables = operation.variables
    ? {
        declaration: ` ${operation.variables.type} ->`,
        parameter: " variables",
        value: `(Maybe.Just <| ${operation.variables.encoder} variables)`
      }
    : {
        declaration: "",
        parameter: "",
        value: "Maybe.Nothing"
      };

  const declaration = `${operation.name} :${
    variables.declaration
  } GraphQL.Operation.Operation GraphQL.Operation.${operation.type} ${
    operation.errors.type
  } ${operation.data.type}`;

  switch (operation.kind) {
    case "query":
      return `${declaration}
${operation.name}${variables.parameter} =
    GraphQL.Operation.withQuery
        ${generateQuery(operation)}
        ${variables.value}
        ${operation.data.decoder}
        ${operation.errors.decoder}`;
    case "named":
      return `${declaration}
${operation.name}${variables.parameter} =
    GraphQL.Operation.withName
        "${operation.gqlName}"
        ${variables.value}
        ${operation.data.decoder}
        ${operation.errors.decoder}`;
    case "named_prefixed":
      return `${declaration}
${operation.name}${variables.parameter} =
    GraphQL.Operation.withName
        "${operation.gqlFilename}:${operation.gqlName}"
        ${variables.value}
        ${operation.data.decoder}
        ${operation.errors.decoder}`;
  }
};

const generateQuery = (operation: ElmQueryOperation): string =>
  wrapQuery(
    operation,
    `"""${operation.query}"""${operation.fragments
      .map(name => `\n            ++ ${name}`)
      .join("")}`
  );

const wrapQuery = (operation: ElmQueryOperation, query: string): string =>
  operation.fragments.length > 0 ? `(${query}\n        )` : query;

const generateFragments = (intel: ElmIntel): string =>
  intel.fragments.map(generateFragment).join("");

const generateFragment = (fragment: ElmFragment): string =>
  `\n\n\n${fragment.name} : String\n${fragment.name} =\n    """${
    fragment.query
  }"""`;

const generateOperationResponses = (intel: ElmIntel): string =>
  intel.operations.map(generateOperationResponse).join("\n\n\n");

const generateOperationResponse = (operation: ElmOperation): string =>
  `type alias ${operation.responseTypeName} =
    GraphQL.Response.Response ${operation.errors.type} ${operation.data.type}`;

//
// ENCODERS AND DECODERS
//

const generateEncodersAndDecoders = (intel: ElmIntel): string => {
  const generatedTypes: string[] = [];
  const items: string[] = [];

  const newType = (type: string, createItems: () => string[]) => {
    if (!generatedTypes.includes(type)) {
      generatedTypes.push(type);
      items.push(...createItems());
    }
  };

  intel.operations.map(operation => {
    if (operation.variables) {
      generateEncoders(operation.variables, newType);
    }
    generateDecoders(operation.data, newType);
  });

  return items.join("\n\n\n");
};

//
// ENCODERS
//

const generateEncoders = (encoder: ElmEncoder, newType): void => {
  visitEncoders(encoder, {
    record: (encoder: ElmRecordEncoder) => {
      newType(encoder.type, () => [
        generateRecordTypeDeclaration(encoder),
        generateRecordEncoder(encoder)
      ]);
    },
    value: (encoder: ElmValueEncoder) => {}
  });
};

const generateRecordEncoder = (encoder: ElmRecordEncoder): string => {
  const hasOptionals = encoder.fields.some(
    field => field.valueWrapper === "optional"
  );

  const objectEncoder = hasOptionals
    ? "GraphQL.Optional.encodeObject"
    : "Json.Encode.object";

  const fieldEncoders = encoder.fields
    .map(
      field =>
        `( "${field.jsonName}", ${wrapEncoder(field, hasOptionals)} inputs.${
          field.name
        } )`
    )
    .join("\n        , ");

  return `${encoder.encoder} : ${encoder.type} -> Json.Encode.Value
${encoder.encoder} inputs =
    ${objectEncoder}
        [ ${fieldEncoders}
        ]`;
};

const wrapEncoder = (
  field: ElmEncoderField,
  hasOptionalSiblings: boolean
): string => {
  let encoder = field.value.encoder;

  if (field.valueListItemWrapper === "optional") {
    encoder = `(GraphQL.Optional.encodeList ${encoder})`;
  } else if (field.valueListItemWrapper === "non-null") {
    encoder = `(List.map ${encoder} >> Json.Encode.list)`;
  }

  if (hasOptionalSiblings) {
    if (field.valueWrapper === "optional") {
      encoder = `(GraphQL.Optional.map ${encoder})`;
    } else {
      encoder = `(${encoder} >> GraphQL.Optional.Present)`;
    }
  }

  return encoder;
};

//
// DECODERS
//

const generateDecoders = (decoder: ElmDecoder, newType): void => {
  visitDecoders(decoder, {
    value: (decoder: ElmValueDecoder) => {},
    constant: (decoder: ElmConstantDecoder) => {},
    record: (decoder: ElmRecordDecoder) => {
      newType(decoder.type, () => [
        generateRecordTypeDeclaration(decoder),
        generateRecordDecoder(decoder)
      ]);
    },
    union: (decoder: ElmUnionDecoder) => {
      newType(decoder.type, () => generateUnionDecoder(decoder));
    },
    unionOn: (decoder: ElmUnionOnDecoder) => {
      newType(decoder.type, () => generateUnionDecoder(decoder));
    },
    empty: (decoder: ElmEmptyDecoder) => {}
  });
};

const generateRecordDecoder = (decoder: ElmRecordDecoder): string => {
  const declaration = `${decoder.decoder} : Json.Decode.Decoder ${
    decoder.type
  }`;

  const { fields } = decoder;

  const map = fields.length > 1 ? Math.min(fields.length, 8) : "";

  const prefix = index =>
    index >= 8 ? "|> GraphQL.Helpers.Decode.andMap " : "";

  const fieldDecoders = fields.map(
    (field, index) =>
      field.value.kind === "union-on-decoder"
        ? `        ${field.value.decoder}`
        : `        ${prefix(index)}(${fieldDecoder(field)} "${
            field.jsonName
          }" ${wrapFieldDecoder(field)})`
  );

  return `${declaration}\n${decoder.decoder} =\n    Json.Decode.map${map} ${
    decoder.type
  }\n${fieldDecoders.join("\n")}`;
};

const fieldDecoder = (field: ElmDecoderField): string => {
  switch (field.valueWrapper) {
    case "optional":
      return "GraphQL.Optional.fieldDecoder";
    case "non-null-optional":
      return "GraphQL.Optional.nonNullFieldDecoder";
    default:
      return "Json.Decode.field";
  }
};

const wrapFieldDecoder = (field: ElmDecoderField): string => {
  let decoder = field.value.decoder;

  if (field.value.kind === "constant-decoder") {
    decoder = `(GraphQL.Helpers.Decode.constant ${
      field.value.value
    } ${decoder})`;
  }

  if (field.valueListItemWrapper === "nullable") {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  if (field.valueListItemWrapper) {
    decoder = `(Json.Decode.list ${decoder})`;
  }

  if (field.valueWrapper === "nullable") {
    decoder = `(Json.Decode.nullable ${decoder})`;
  }

  return decoder;
};

const generateUnionDecoder = (
  decoder: ElmUnionDecoder | ElmUnionOnDecoder
): string[] => {
  const constructors = decoder.constructors.sort(
    (a, b) => numberOfChildren(b) - numberOfChildren(a)
  );

  const constructorDeclarations = constructors.map(
    (constructor: ElmUnionConstructor): string => {
      switch (constructor.decoder.kind) {
        case "record-decoder":
        case "union-decoder":
          return `${constructor.name} ${constructor.decoder.type}`;
        case "empty-decoder":
          return constructor.name;
      }
    }
  );

  const typeDeclaration = `type ${
    decoder.type
  }\n    = ${constructorDeclarations.join("\n    | ")}`;

  const decoderDeclaration = `${decoder.decoder} : Json.Decode.Decoder ${
    decoder.type
  }`;

  const constructorDecoders = constructors.map(
    (constructor: ElmUnionConstructor): string => {
      switch (constructor.decoder.kind) {
        case "record-decoder":
        case "union-decoder":
          return `Json.Decode.map ${constructor.name} ${
            constructor.decoder.decoder
          }`;
        case "empty-decoder":
          return `${constructor.decoder.decoder} ${constructor.name}`;
      }
    }
  );

  const typeDecoder = `${
    decoder.decoder
  } =\n    Json.Decode.oneOf\n        [ ${constructorDecoders.join(
    "\n        , "
  )}\n        ]`;

  return [typeDeclaration, `${decoderDeclaration}\n${typeDecoder}`];
};

const numberOfChildren = (constructor: ElmUnionConstructor): number => {
  switch (constructor.decoder.kind) {
    case "record-decoder":
      return constructor.decoder.fields.length;
    case "union-decoder":
      return constructor.decoder.constructors.length;
    case "empty-decoder":
      return 0;
  }
};

//
// RECORD TYPE DECLARATION
//

const generateRecordTypeDeclaration = (
  item: ElmRecordEncoder | ElmRecordDecoder
): string => {
  const fields: ElmRecordField[] = item.fields;
  const fieldTypes: string[] = fields.map(
    field => `${field.name} : ${wrappedType(field)}`
  );

  return `type alias ${item.type} =\n    { ${fieldTypes.join(
    "\n    , "
  )}\n    }`;
};

const wrappedType = (field: ElmRecordField): string => {
  let signature = field.value.type;
  let wrap = x => x;

  switch (field.valueListItemWrapper) {
    case "nullable":
      signature = `Maybe.Maybe ${signature}`;
      wrap = withParentheses;
      break;
    case "optional":
      signature = `GraphQL.Optional.Optional ${signature}`;
      wrap = withParentheses;
      break;
  }

  if (field.valueListItemWrapper) {
    signature = `List ${wrap(signature)}`;
    wrap = withParentheses;
  }

  switch (field.valueWrapper) {
    case "nullable":
    case "non-null-optional":
      signature = `Maybe.Maybe ${wrap(signature)}`;
      break;
    case "optional":
      signature = `GraphQL.Optional.Optional ${wrap(signature)}`;
      break;
  }

  return signature;
};

//
// VISITORS
//

type EncoderVisitor = {
  record: (encoder: ElmRecordEncoder) => void;
  value: (encoder: ElmValueEncoder) => void;
};

const visitEncoders = (encoder: ElmEncoder, visitor: EncoderVisitor) => {
  switch (encoder.kind) {
    case "record-encoder":
      visitor.record(encoder);
      encoder.fields.forEach(field => visitEncoders(field.value, visitor));
      break;
    case "value-encoder":
      visitor.value(encoder);
      break;
  }
};

type DecoderVisitor = {
  value: (decoder: ElmValueDecoder) => void;
  constant: (decoder: ElmConstantDecoder) => void;
  record: (decoder: ElmRecordDecoder) => void;
  union: (decoder: ElmUnionDecoder) => void;
  unionOn: (decoder: ElmUnionOnDecoder) => void;
  empty: (decoder: ElmEmptyDecoder) => void;
};

const visitDecoders = (decoder: ElmDecoder, visitor: DecoderVisitor) => {
  switch (decoder.kind) {
    case "value-decoder":
      visitor.value(decoder);
      break;
    case "constant-decoder":
      visitor.constant(decoder);
      break;
    case "record-decoder":
      visitor.record(decoder);
      decoder.fields.forEach(field => visitDecoders(field.value, visitor));
      break;
    case "union-decoder":
      visitor.union(decoder);
      decoder.constructors.forEach(constructor =>
        visitDecoders(constructor.decoder, visitor)
      );
      break;
    case "union-on-decoder":
      visitor.unionOn(decoder);
      decoder.constructors.forEach(constructor =>
        visitDecoders(constructor.decoder, visitor)
      );
      break;
    case "empty-decoder":
      visitor.empty(decoder);
      break;
  }
};
