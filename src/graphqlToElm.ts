import { resolve } from "path";
import { GraphQLSchema, buildSchema } from "graphql";
import {
  Options,
  FinalOptions,
  SchemaString,
  finalizeOptions
} from "./options";
import * as enums from "./enums";
import { EnumIntel } from "./enums";
import { QueryIntel, readQueryIntel } from "./queries/queryIntel";
import { ElmIntel, queryToElmIntel } from "./queries/elmIntel";
import { generateElm } from "./queries/generateElm";
import { readFile, writeFile } from "./utils";

export interface Result {
  enums: EnumIntel[];
  queries: QueryResult[];
  options: FinalOptions;
}

export interface QueryResult {
  queryIntel: QueryIntel;
  elmIntel: ElmIntel;
}

export const graphqlToElm = (options: Options): Result => {
  const result: Result = getGraphqlToElm(options);
  writeResult(result);
  return result;
};

export const getGraphqlToElm = (userOptions: Options): Result => {
  let options: FinalOptions = finalizeOptions(userOptions);

  const schema: GraphQLSchema = buildSchema(getSchemaString(options));

  options.log(`processing enums`);
  const enumsIntel: EnumIntel[] = enums.getIntel(schema, options);

  options = {
    ...options,
    enumEncoders: { ...enums.getEncoders(enumsIntel), ...options.enumEncoders },
    enumDecoders: { ...enums.getDecoders(enumsIntel), ...options.enumDecoders }
  };

  const queriesResults = options.queries.map(src => {
    const queryIntel = readQueryIntel(src, schema, options);
    const elmIntel = queryToElmIntel(queryIntel, options);

    return {
      queryIntel,
      elmIntel
    };
  });

  return {
    enums: enumsIntel,
    queries: queriesResults,
    options
  };
};

export const getSchemaString = ({
  schema,
  log
}: {
  schema: string | SchemaString;
  log?: (message: string) => void;
}): string => {
  if (typeof schema === "string") {
    log && log(`reading schema ${schema}`);
    return readFile(schema);
  } else {
    log && log("reading schema from string");
    return schema.string;
  }
};

export const writeResult = (result: Result): void => {
  result.enums.forEach(enumIntel => {
    result.options.log(`writing ${enumIntel.dest}`);
    writeFile(enumIntel.dest, enums.generateElm(enumIntel));
  });

  result.queries.forEach(({ elmIntel }) => {
    result.options.log(`writing ${elmIntel.dest}`);
    writeFile(elmIntel.dest, generateElm(elmIntel));
  });

  elmFiles.forEach(filename => {
    const src = resolve(__dirname, "../elm/GraphQL", filename);
    const dest = resolve(result.options.dest, "GraphQL", filename);
    result.options.log(`writing ${dest}`);
    writeFile(dest, readFile(src));
  });

  result.options.log("done");
};

const elmFiles = [
  "Batch.elm",
  "Errors.elm",
  "Operation.elm",
  "Optional.elm",
  "PlainBatch.elm",
  "Response.elm",
  "Helpers/Decode.elm",
  "Helpers/Url.elm",
  "Http/Basic.elm"
];
