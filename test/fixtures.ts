import { Options, TypeDecoders } from "../src/options";

export interface Fixture {
  id: string;
  dir: string;
  options: Options;
  expect: string;
}

export const getFixtures = (fixtureId?: string): Fixture[] =>
  Object.keys(data)
    .map(key => ({
      id: key,
      dir: `fixtures/${key}`,
      ...data[key]
    }))
    .filter(fixture => !fixtureId || fixture.id === fixtureId);

interface Config {
  schema?: string;
  queries: string[];
  scalarDecoders?: TypeDecoders;
  enumDecoders?: TypeDecoders;
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
  enumDecoders,
  src,
  dest = "generated-output",
  expect = "expected-output"
}: Config): FinalConfig => ({
  options: {
    schema,
    queries,
    scalarDecoders,
    enumDecoders,
    src,
    dest
  },
  expect
});

const data: { [key: string]: FinalConfig } = {
  "line-endings": create({ queries: ["lf.gql", "crlf.gql"] }),
  keywords: create({ queries: ["query.gql"] }),
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
      //   - see also keywords
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
  }),
  enums: create({
    queries: ["enum.gql", "nullable-enum.gql"],
    enumDecoders: {
      Binary: {
        type: "Data.Binary.Binary",
        decoder: "Data.Binary.decoder"
      }
    }
  }),
  variables: create({
    queries: [
      "scalars.gql",
      "scalars-optional.gql",
      "scalars-mixed.gql",
      "inputs.gql",
      "inputs-optional.gql",
      "inputs-mixed.gql",
      "lists.gql"
    ]
  })
  // TODO
  // - endpoint
  // - field names
  // - interfaces
  // - directives
  // - mutations
  // - swapi
  // - unions
};
