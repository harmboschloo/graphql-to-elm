import * as assert from "assert";
import { withDefault } from "./utils";

export interface Options {
  schema: string | SchemaString;
  enums?: EnumOptions;
  queries: string[];
  scalarEncoders?: TypeEncoders;
  enumEncoders?: TypeEncoders;
  scalarDecoders?: TypeDecoders;
  enumDecoders?: TypeDecoders;
  errorsDecoder?: TypeDecoder;
  src?: string;
  dest?: string;
  operationKind?: "query" | "named" | "named_prefixed";
  log?: (message: string) => void;
}

export interface SchemaString {
  string: string;
}

export interface EnumOptions {
  baseModule?: string;
}

export interface FinalOptions {
  schema: string | SchemaString;
  enums: FinalEnumOptions;
  queries: string[];
  scalarEncoders: TypeEncoders;
  enumEncoders: TypeEncoders;
  scalarDecoders: TypeDecoders;
  enumDecoders: TypeDecoders;
  errorsDecoder: TypeDecoder;
  src: string;
  dest: string;
  operationKind: "query" | "named" | "named_prefixed";
  log: (message: string) => void;
}

export interface FinalEnumOptions {
  baseModule: string;
}

export interface TypeEncoders {
  [graphqlType: string]: TypeEncoder;
}

export interface TypeEncoder {
  type: string;
  encoder: string;
}

export interface TypeDecoders {
  [graphqlType: string]: TypeDecoder;
}

export interface TypeDecoder {
  type: string;
  decoder: string;
}

const defaultEnumOptions: FinalEnumOptions = {
  baseModule: "GraphQL.Enum"
};

const defaultScalarEncoders: TypeEncoders = {
  Int: {
    type: "Int",
    encoder: "Json.Encode.int"
  },
  Float: {
    type: "Float",
    encoder: "Json.Encode.float"
  },
  Boolean: {
    type: "Bool",
    encoder: "Json.Encode.bool"
  },
  String: {
    type: "String",
    encoder: "Json.Encode.string"
  },
  ID: {
    type: "String",
    encoder: "Json.Encode.string"
  }
};

const defaultScalarDecoders: TypeDecoders = {
  Int: {
    type: "Int",
    decoder: "Json.Decode.int"
  },
  Float: {
    type: "Float",
    decoder: "Json.Decode.float"
  },
  Boolean: {
    type: "Bool",
    decoder: "Json.Decode.bool"
  },
  String: {
    type: "String",
    decoder: "Json.Decode.string"
  },
  ID: {
    type: "String",
    decoder: "Json.Decode.string"
  }
};

const defaultErrorsDecoder: TypeDecoder = {
  type: "GraphQL.Errors.Errors",
  decoder: "GraphQL.Errors.decoder"
};

export const finalizeOptions = (options: Options): FinalOptions => {
  validateOptions(options);

  const { schema, queries } = options;

  const enums = {
    ...defaultEnumOptions,
    ...withDefault({}, options.enums)
  };

  const scalarEncoders = {
    ...defaultScalarEncoders,
    ...withDefault({}, options.scalarEncoders)
  };
  const enumEncoders = withDefault({}, options.enumEncoders);
  const scalarDecoders = {
    ...defaultScalarDecoders,
    ...withDefault({}, options.scalarDecoders)
  };
  const enumDecoders = withDefault({}, options.enumDecoders);
  const errorsDecoder = withDefault(
    defaultErrorsDecoder,
    options.errorsDecoder
  );
  const src = withDefault(".", options.src);
  const dest = withDefault(src, options.dest);
  const operationKind = withDefault("query", options.operationKind);
  const log =
    typeof options.log !== "undefined"
      ? options.log || (x => {})
      : message => console.log(message);

  return {
    schema,
    enums,
    queries,
    scalarEncoders,
    enumEncoders,
    scalarDecoders,
    enumDecoders,
    errorsDecoder,
    src,
    dest,
    operationKind,
    log
  };
};

const validateOptions = (options: Options) => {
  assert.strictEqual(typeof options, "object", "options must be an object");

  validateSchema(options.schema);
  validateEnums(options.enums);
  validateQueries(options.queries);
  validateTypeEncoders("scalarEncoders", options.scalarEncoders);
  validateTypeEncoders("enumEncoders", options.enumEncoders);
  validateTypeDecoders("scalarDecoders", options.scalarDecoders);
  validateTypeDecoders("enumDecoders", options.enumDecoders);
  validateErrorsDecoder(options.errorsDecoder);
  validateSrc(options.src);
  validateDest(options.dest);
  validateOperationKind(options.operationKind);
  validateLog(options.log);
};

const validateSchema = (schema: string | SchemaString) => {
  if (typeof schema === "string") {
    // ok
    return;
  }

  if (typeof schema === "object" && schema !== null) {
    if (typeof schema.string === "string") {
      //ok
      return;
    }
  }

  assert.fail(
    `options.schema must be a string or and object of type SchemaString, but found: ${schema}`
  );
};

const validateEnums = (enums?: EnumOptions) => {
  if (typeof enums === "undefined") {
    return;
  }

  assert.strictEqual(
    enums && typeof enums,
    "object",
    `options.enums must be an object, but found: ${enums}`
  );

  if (typeof enums.baseModule !== "undefined") {
    assert.strictEqual(
      typeof enums.baseModule,
      "string",
      `options.enums.baseModule must be a string, but found: ${
        enums.baseModule
      }`
    );
  }
};

const validateQueries = (queries: string[]) => {
  assert.strictEqual(
    Array.isArray(queries),
    true,
    `options.queries must be an array, but found: ${queries}`
  );

  queries.forEach(query =>
    assert.strictEqual(
      typeof query,
      "string",
      `options.queries must only contain strings, but found: ${query}`
    )
  );
};

const validateTypeEncoders = (name: string, typeEncoders?: TypeEncoders) => {
  if (typeof typeEncoders === "undefined") {
    return;
  }

  assert.strictEqual(
    typeEncoders && typeof typeEncoders,
    "object",
    `options.${name} must be an object, but found: ${typeEncoders}`
  );

  Object.keys(typeEncoders).forEach(key =>
    validateTypeEncoder(name, typeEncoders[key])
  );
};

const validateTypeEncoder = (name: string, typeEncoder: TypeEncoder) => {
  const message = `options.${name} must contain fields of TypeEncoder: {type: string, encoder: string} , but found: ${typeEncoder}`;

  assert.strictEqual(typeEncoder && typeof typeEncoder, "object", message);
  assert.strictEqual(typeof typeEncoder.type, "string", message);
  assert.strictEqual(typeof typeEncoder.encoder, "string", message);
};

const validateTypeDecoders = (name: string, typeDecoders?: TypeDecoders) => {
  if (typeof typeDecoders === "undefined") {
    return;
  }

  assert.strictEqual(
    typeDecoders && typeof typeDecoders,
    "object",
    `options.${name} must be an object, but found: ${typeDecoders}`
  );

  Object.keys(typeDecoders).forEach(key =>
    validateTypeDecoder(name, typeDecoders[key])
  );
};

const validateTypeDecoder = (name: string, typeDecoder: TypeDecoder) => {
  const message = `options.${name} must contain fields of TypeDecoder: {type: string, decoder: string} , but found: ${typeDecoder}`;

  assert.strictEqual(typeDecoder && typeof typeDecoder, "object", message);
  assert.strictEqual(typeof typeDecoder.type, "string", message);
  assert.strictEqual(typeof typeDecoder.decoder, "string", message);
};

const validateErrorsDecoder = (typeDecoder?: TypeDecoder) => {
  if (typeof typeDecoder === "undefined") {
    return;
  }

  const message = `options.errorsDecoder must be a TypeDecoder: {type: string, decoder: string} , but found: ${typeDecoder}`;

  assert.strictEqual(typeDecoder && typeof typeDecoder, "object", message);
  assert.strictEqual(typeof typeDecoder.type, "string", message);
  assert.strictEqual(typeof typeDecoder.decoder, "string", message);
};

const validateSrc = (src?: string) => {
  if (typeof src === "undefined") {
    return;
  }

  assert.strictEqual(
    typeof src,
    "string",
    `options.src must be a string, but found: ${src}`
  );
};

const validateDest = (dest?: string) => {
  if (typeof dest === "undefined") {
    return;
  }

  assert.strictEqual(
    typeof dest,
    "string",
    `options.dest must be a string, but found: ${dest}`
  );
};

const validateOperationKind = (operationKind?: string) => {
  if (typeof operationKind === "undefined") {
    return;
  }

  assert.strictEqual(
    operationKind === "query" ||
      operationKind === "named" ||
      operationKind === "named_prefixed",
    true,
    `options.operationKind must be "query", "named" or "named_prefixed", but found: ${operationKind}`
  );
};

const validateLog = (log?: (message: string) => void) => {
  if (typeof log === "undefined") {
    return;
  }

  assert.strictEqual(
    log === null || typeof log === "function",
    true,
    `options.log must be "null" or a function, but found: ${log}`
  );
};
