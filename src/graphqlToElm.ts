import { GraphQLSchema, buildSchema } from "graphql";
import { Options, FinalOptions, finalizeOptions } from "./options";
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

  options.log(`reading schema ${options.schema}`);
  const schema: GraphQLSchema = buildSchema(readFile(options.schema));

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

export const writeResult = (result: Result): void => {
  result.enums.forEach(enumIntel => {
    result.options.log(`writing ${enumIntel.dest}`);
    writeFile(enumIntel.dest, enums.generateElm(enumIntel));
  });

  result.queries.forEach(({ elmIntel }) => {
    result.options.log(`writing ${elmIntel.dest}`);
    writeFile(elmIntel.dest, generateElm(elmIntel));
  });

  result.options.log("done");
};
