interface Config {
  schema?: string;
  queries: string[];
  src?: string;
  dest?: string;
  expect?: string;
}

const create = ({
  schema = "schema.gql",
  queries,
  src = "",
  dest = "generated-output",
  expect = "expected-output"
}: Config) => ({
  schema,
  queries,
  src,
  dest,
  expect
});

const data = {
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
  })
  // TODO
  // - endpoint
  // - field names
  // - interfaces
  // - directives
  // - mutations
  // - swapi
  // - custom scalars
  // - enums
  // - unions
  // - variables
};

export interface Fixture {
  id: string;
  dir: string;
  schema: string;
  queries: string[];
  src: string;
  dest: string;
  expect: string;
}

export const getFixtures = (): Fixture[] =>
  Object.keys(data).map(key => ({
    id: key,
    dir: key,
    ...data[key]
  }));
