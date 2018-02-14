export interface Options {
  schema: string;
  queries: string[];
  scalarDecoders?: ScalarDecoders;
  src?: string;
  dest?: string;
  log?: (message: string) => void;
}

export interface FinalOptions {
  schema: string;
  queries: string[];
  scalarDecoders: ScalarDecoders;
  src: string;
  dest: string;
  log: (message: string) => void;
}

export interface ScalarDecoders {
  [scalarType: string]: ScalarDecoder;
}

export interface ScalarDecoder {
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
  const scalarDecoders = withDefault({}, options.scalarDecoders);
  const src = withDefault(".", options.src);
  const dest = withDefault(src, options.dest);
  const log =
    typeof options.log !== "undefined"
      ? options.log || (x => {})
      : message => console.log(message);

  return { schema, queries, scalarDecoders, src, dest, log };
};

const withDefault = (defaultValue, value) =>
  value !== null && typeof value !== "undefined" ? value : defaultValue;
