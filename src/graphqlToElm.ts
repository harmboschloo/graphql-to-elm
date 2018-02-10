import { GraphQLSchema, buildSchema } from "graphql";
import { Options, log } from "./options";
import { QueryIntel, readQueryIntel } from "./queryIntel";
import { ElmIntel, queryToElmIntel } from "./elmIntel";
import { generateElm } from "./generateElm";
import { readFile, writeFile } from "./utils";

export interface Result {
  queries: QueryResult[];
  options: Options;
}

export interface QueryResult {
  queryIntel: QueryIntel;
  elmIntel: ElmIntel;
  elm: string;
}

const defaultOptions: { log: (message: string) => void } = {
  log: message => console.log(message)
};

export const graphqlToElm = (options: Options): Result => {
  const result: Result = getGraphqlToElm(options);
  writeResult(result);
  return result;
};

export const getGraphqlToElm = (options: Options): Result => {
  options = { ...defaultOptions, ...options };

  log(`reading schema ${options.schema}`, options);
  const schema = buildSchema(readFile(options.schema));

  const queriesResults = options.queries.map(src => {
    const queryIntel = readQueryIntel(src, schema, options);
    const elmIntel = queryToElmIntel(queryIntel, options);
    const elm = generateElm(elmIntel);

    return {
      queryIntel,
      elmIntel,
      elm
    };
  });

  return { queries: queriesResults, options };
};

export const writeResult = (result: Result): void => {
  result.queries.forEach(({ elmIntel, elm }) => {
    log(`writing ${elmIntel.dest}`, result.options);
    writeFile(elmIntel.dest, elm);
  });

  log("done", result.options);
};
