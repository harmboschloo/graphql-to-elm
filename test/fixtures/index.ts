import { resolve } from "path";
import { rimraf } from "../utils";
import { Options, SchemaString, TypeDecoders } from "../../src/options";

export interface Fixture {
  id: string;
  dir: string;
  options: Options;
  actual: string;
  expect: string;
  throws?: string;
}

export const clean = () => rimraf(resolve(__dirname, "**/generated*"));

export type FixturesConfig = {
  graphqlVersion: "0.12" | "0.13";
  onlyFixtureWithId?: string;
};

export const getFixtures = (config: FixturesConfig): Fixture[] => {
  const data = getData(config.graphqlVersion);
  return Object.keys(data)
    .map(key => ({
      id: key,
      dir: resolve(__dirname, key),
      ...data[key]
    }))
    .filter(
      fixture =>
        !config.onlyFixtureWithId || fixture.id === config.onlyFixtureWithId
    );
};

interface Config {
  schema?: string | SchemaString;
  queries: string[];
  scalarDecoders?: TypeDecoders;
  enumDecoders?: TypeDecoders;
  src?: string;
  dest?: string;
  operationKind?: "query" | "named" | "named_prefixed";
  expect?: string;
  throws?: string;
}

interface FinalConfig {
  options: Options;
  expect: string;
  actual: string;
  throws?: string;
}

const create = ({
  schema = "schema.gql",
  queries,
  scalarDecoders,
  enumDecoders,
  src,
  dest = "generated-output",
  operationKind,
  expect = "expected-output",
  throws
}: Config): FinalConfig => ({
  options: {
    schema,
    queries,
    scalarDecoders,
    enumDecoders,
    src,
    dest,
    operationKind
  },
  actual: dest,
  expect,
  throws
});

const getData = (
  graphqlVersion: "0.12" | "0.13"
): { [key: string]: FinalConfig } => ({
  aliases: create({ queries: ["query.gql"] }),

  customScalars: create({
    queries: ["custom-scalar-types.gql", "custom-nullable-scalar-types.gql"],
    scalarDecoders: {
      ID: {
        type: "Data.Id.Id",
        decoder: "Data.Id.decoder"
      },
      Time: {
        type: "Data.Time.Posix",
        decoder: "Data.Time.decoder"
      }
    }
  }),

  directives: create({
    queries: ["include.gql", "skip.gql", "mixed1.gql", "mixed2.gql"]
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

  fragments: create({
    queries: ["query.gql"]
  }),

  "inline-fragments": create({
    queries: [
      "union.gql",
      "union-list.gql",
      "union-partial.gql",
      "interface.gql",
      "interface-plain.gql",
      "interface-list.gql",
      "interface-list-shared.gql",
      "interface-shared.gql",
      "interface-partial.gql",
      "interface-partial-shared.gql",
      "interface-multiple.gql",
      "names.gql",
      "single.gql",
      "typename.gql",
      "typename-shared.gql",
      "typename-shared-more.gql",
      "fragment-in-fragment.gql",
      "fragment-in-fragment-shared.gql",
      "fragment-in-fragment-partial.gql"
    ],
    schema: graphqlVersion === "0.12" ? "schema-0.12.gql" : "schema-0.13.gql"
  }),

  "inline-fragments-throws": create({
    queries: ["same-signature.gql"],
    throws:
      "multiple union constructors with the same decode signature: color : String"
  }),

  keywords: create({ queries: ["query.gql"] }),

  lists: create({ queries: ["list-of-objects.gql", "list-of-scalars.gql"] }),

  misc: create({ queries: ["query.gql"] }),

  names: create({ queries: ["queries.gql"] }),

  objects: create({
    queries: [
      "basic.gql",
      "big.gql",
      "nested.gql",
      "same-type-same-fields.gql",
      "same-type-same-fields-nullable.gql",
      "same-type-same-fields-list.gql",
      "same-type-other-fields.gql",
      "other-type-same-fields.gql",
      "other-type-other-fields.gql",
      "recursive.gql"
    ]
  }),

  operations: create({
    queries: [
      "anonymous-query.gql",
      "anonymous-mutation.gql",
      "multiple.gql",
      "multiple-fragments.gql"
    ]
  }),

  "operations-named": create({
    queries: ["query.gql"],
    operationKind: "named"
  }),

  "operations-named_prefixed": create({
    src: resolve(__dirname, "operations-named_prefixed"),
    queries: [
      "query.gql",
      resolve(__dirname, "operations-named_prefixed/Queries/Query.gql"),
      "queries2/Queries/query2.gql"
    ],
    operationKind: "named_prefixed"
  }),

  scalars: create({
    queries: ["default-scalar-types.gql", "default-nullable-scalar-types.gql"]
  }),

  "schema-string": create({
    schema: {
      string: `# Schema

      schema {
        query: Query
      }
      
      # Query
      
      type Query {
        hello: String!
      }
      `
    },
    queries: ["query.gql"]
  }),

  variables: create({
    queries: [
      "scalars.gql",
      "scalars-optional.gql",
      "scalars-mixed.gql",
      "inputs.gql",
      "inputs-optional.gql",
      "inputs-mixed.gql",
      "inputs-multiple.gql",
      "lists.gql"
    ]
  })
});
