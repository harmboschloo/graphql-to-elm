import { Options, ScalarDecoders } from "../src/options";

export interface Fixture {
  id: string;
  dir: string;
  options: Options;
  expect: string;
}

export const getFixtures = (): Fixture[] =>
  Object.keys(data).map(key => ({
    id: key,
    dir: `fixtures/${key}`,
    ...data[key]
  }));

interface Config {
  schema?: string;
  queries: string[];
  scalarDecoders?: ScalarDecoders;
  src?: string;
  dest?: string;
  expect?: string;
}

interface FinalConfig {
  options: Options;
  expect: string;
}

const create = ({
  schema = "schema.gql",
  queries,
  scalarDecoders,
  src,
  dest = "generated-output",
  expect = "expected-output"
}: Config): FinalConfig => ({
  options: {
    schema,
    queries,
    scalarDecoders,
    src,
    dest
  },
  expect
});

const data: { [key: string]: FinalConfig } = {
  "line-endings": create({ queries: ["lf.gql", "crlf.gql"] }),
  lists: create({ queries: ["list-of-objects.gql", "list-of-scalars.gql"] }),
  misc: create({ queries: ["query.gql"] }),
  objects: create({
    queries: [
      "basic.gql",
      "nested.gql",
      "same-type-same-fields.gql",
      "same-type-same-fields-nullable.gql",
      "same-type-same-fields-list.gql",
      "same-type-other-fields.gql",
      "other-type-same-fields.gql",
      "other-type-other-fields.gql"
      // TODO
      // - big objects (more than 8 fields, needs andMap)
      // - resursive decoding? (using lazy)
    ]
  }),
  scalars: create({
    queries: ["default-scalar-types.gql", "default-nullable-scalar-types.gql"]
  }),
  customScalars: create({
    queries: ["custom-scalar-types.gql", "custom-nullable-scalar-types.gql"],
    scalarDecoders: {
      ID: {
        type: "Data.Id.Id",
        decoder: "Data.Id.decoder"
      },
      Date: {
        type: "Data.Date.Date",
        decoder: "Data.Date.decoder"
      }
    }
  })
  // TODO
  // - endpoint
  // - field names
  // - interfaces
  // - directives
  // - mutations
  // - swapi
  // - enums
  // - unions
  // - variables
};
