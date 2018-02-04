import { readFileSync, writeFileSync } from "fs";
import { dirname } from "path";
import * as mkdirp from "mkdirp";
import { GraphQLSchema, buildSchema } from "graphql";
import { Options, log } from "./options";
import { QueryIntel, readQueryIntel } from "./queryIntel";
import { ElmIntel, queryToElmIntel } from "./elmIntel";
import { generateElm } from "./generateElm";

export interface Result {
  queries: QueryResult[];
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

  result.queries.forEach(({ elmIntel, elm }) => {
    log(`writing ${elmIntel.dest}`, options);
    mkdirp.sync(dirname(elmIntel.dest));
    writeFileSync(elmIntel.dest, elm, "utf8");
  });

  log("done", options);

  return result;
};

export const getGraphqlToElm = (options: Options): Result => {
  options = { ...defaultOptions, ...options };

  log(`reading schema ${options.schema}`, options);
  const schema = buildSchema(readFileSync(options.schema, "utf8"));

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

  return { queries: queriesResults };
};
