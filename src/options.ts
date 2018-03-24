import { withDefault } from "./utils";

export interface Options {
  schema: string;
  queries: string[];
  scalarEncoders?: TypeEncoders;
  enumEncoders?: TypeEncoders;
  scalarDecoders?: TypeDecoders;
  enumDecoders?: TypeDecoders;
  errorsDecoder?: TypeDecoder;
  src?: string;
  dest?: string;
  operationType?: "query" | "named";
  log?: (message: string) => void;
}

export interface FinalOptions {
  schema: string;
  queries: string[];
  scalarEncoders: TypeEncoders;
  enumEncoders: TypeEncoders;
  scalarDecoders: TypeDecoders;
  enumDecoders: TypeDecoders;
  errorsDecoder: TypeDecoder;
  src: string;
  dest: string;
  operationType: "query" | "named";
  log: (message: string) => void;
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
  type: "GraphqlToElm.Errors.Errors",
  decoder: "GraphqlToElm.Errors.decoder"
};

export const finalizeOptions = (options: Options): FinalOptions => {
  const { schema, queries } = options;
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
  const operationType = withDefault("query", options.operationType);
  const log =
    typeof options.log !== "undefined"
      ? options.log || (x => {})
      : message => console.log(message);

  return {
    schema,
    queries,
    scalarEncoders,
    enumEncoders,
    scalarDecoders,
    enumDecoders,
    errorsDecoder,
    src,
    dest,
    operationType,
    log
  };
};
