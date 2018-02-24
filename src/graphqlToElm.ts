import { GraphQLSchema, buildSchema } from "graphql";
import { Options, FinalOptions, finalize } from "./options";
import { QueryIntel, readQueryIntel } from "./queryIntel";
import { ElmIntel } from "./elmIntelTypes";
import { queryToElmIntel } from "./elmIntel";
import { generateElm } from "./generateElm";
import { readFile, writeFile } from "./utils";

export interface Result {
  queries: QueryResult[];
  options: FinalOptions;
}

export interface QueryResult {
  queryIntel: QueryIntel;
  elmIntel: ElmIntel;
  elm: string;
}

export const graphqlToElm = (options: Options): Result => {
  const result: Result = getGraphqlToElm(options);
  writeResult(result);
  return result;
};

export const getGraphqlToElm = (userOptions: Options): Result => {
  const options: FinalOptions = finalize(userOptions);

  options.log(`reading schema ${options.schema}`);
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
    result.options.log(`writing ${elmIntel.dest}`);
    writeFile(elmIntel.dest, elm);
  });

  result.options.log("done");
};
