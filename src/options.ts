export interface Options {
  schema: string;
  queries: string[];
  scalarEncoders?: TypeEncoders;
  enumEncoders?: TypeEncoders;
  scalarDecoders?: TypeDecoders;
  enumDecoders?: TypeDecoders;
  src?: string;
  dest?: string;
  log?: (message: string) => void;
}

export interface FinalOptions {
  schema: string;
  queries: string[];
  scalarEncoders: TypeEncoders;
  enumEncoders: TypeEncoders;
  scalarDecoders: TypeDecoders;
  enumDecoders: TypeDecoders;
  src: string;
  dest: string;
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

const defaultOptions: {
  src: string;
  dest: string;
  log: (message: string) => void;
} = {
  src: ".",
  dest: ".",
  log: message => console.log(message)
};

export const finalize = (options: Options): FinalOptions => {
  const { schema, queries } = options;
  const scalarEncoders = withDefault({}, options.scalarEncoders);
  const enumEncoders = withDefault({}, options.enumEncoders);
  const scalarDecoders = withDefault({}, options.scalarDecoders);
  const enumDecoders = withDefault({}, options.enumDecoders);
  const src = withDefault(".", options.src);
  const dest = withDefault(src, options.dest);
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
    src,
    dest,
    log
  };
};

const withDefault = (defaultValue, value) =>
  value !== null && typeof value !== "undefined" ? value : defaultValue;
