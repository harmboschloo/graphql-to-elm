import { resolve } from "path";
import { GraphQLSchema, buildSchema } from "graphql";
import { elmSrc, elmFiles } from "graphql-to-elm-package";
import { Options, FinalOptions, finalizeOptions } from "./options";
import { getSchemaString } from "./schema";
import * as enums from "./enums";
import { EnumIntel } from "./enums";
import { QueryIntel, readQueryIntel } from "./queries/queryIntel";
import { ElmIntel, queryToElmIntel } from "./queries/elmIntel";
import { generateElm } from "./queries/generateElm";
import { readFile, writeFileIfChanged } from "./utils";

export interface Result {
  enums: EnumIntel[];
  queries: QueryResult[];
  options: FinalOptions;
}

export interface QueryResult {
  queryIntel: QueryIntel;
  elmIntel: ElmIntel;
}

export const graphqlToElm = (options: Options): Promise<void> => {
  return getGraphqlToElm(options)
    .then(writeResult)
    .then(() => {});
};

export const getGraphqlToElm = (userOptions: Options): Promise<Result> => {
  let options: FinalOptions = finalizeOptions(userOptions);

  return getSchemaString(options).then((schemaString: string) => {
    options.log(`processing schema`);
    const schema: GraphQLSchema = buildSchema(schemaString);

    options.log(`processing enums`);
    const enumsIntel: EnumIntel[] = enums.getIntel(schema, options);

    options = {
      ...options,
      enumEncoders: {
        ...enums.getEncoders(enumsIntel),
        ...options.enumEncoders
      },
      enumDecoders: {
        ...enums.getDecoders(enumsIntel),
        ...options.enumDecoders
      }
    };

    return Promise.all(
      options.queries.map(src =>
        readQueryIntel(src, schema, options).then(queryIntel => ({
          queryIntel,
          elmIntel: queryToElmIntel(queryIntel, options)
        }))
      )
    ).then(queriesResults => ({
      enums: enumsIntel,
      queries: queriesResults,
      options
    }));
  });
};

export const writeResult = (result: Result): Promise<Result> => {
  const writeEnums = Promise.all(
    result.enums.map(enumIntel => {
      return writeFileIfChanged(
        enumIntel.dest,
        enums.generateElm(enumIntel)
      ).then(logWrite(result.options, "enum", enumIntel.dest));
    })
  );

  const writeQueries = Promise.all(
    result.queries.map(({ elmIntel }) => {
      return writeFileIfChanged(elmIntel.dest, generateElm(elmIntel)).then(
        logWrite(result.options, "query", elmIntel.dest)
      );
    })
  );

  const writeLib = Promise.all(
    elmFiles.map(file => {
      const src = resolve(elmSrc, file);
      const dest = resolve(result.options.dest, file);
      return readFile(src)
        .then(data => writeFileIfChanged(dest, data))
        .then(logWrite(result.options, "lib", dest));
    })
  );

  return Promise.all([writeEnums, writeQueries, writeLib])
    .then(() => result.options.log("done"))
    .then(() => result);
};

const logWrite = (options: FinalOptions, label: string, dest: string) => (
  changed: boolean
): void => {
  if (changed) {
    options.log(`${label} file written: ${dest}`);
  }
};
