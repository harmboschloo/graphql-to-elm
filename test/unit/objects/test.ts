import { graphqlToElm, compareDirs } from "../../lib";

const name = "objects";
const schema = "src/schema.gql";
const src = "src";
const dest = "generated-output";

graphqlToElm(`${name} basic`, {
  schema,
  queries: ["src/basic.gql"],
  src,
  dest
});

graphqlToElm(`${name} nested`, {
  schema,
  queries: ["src/nested.gql"],
  src,
  dest
});

graphqlToElm(`${name} same-type-same-fields`, {
  schema,
  queries: ["src/same-type-same-fields.gql"],
  src,
  dest
});

graphqlToElm(`${name} same-type-same-fields-nullable`, {
  schema,
  queries: ["src/same-type-same-fields-nullable.gql"],
  src,
  dest
});

graphqlToElm(`${name} same-type-same-fields-list`, {
  schema,
  queries: ["src/same-type-same-fields-list.gql"],
  src,
  dest
});

graphqlToElm(`${name} same-type-other-fields`, {
  schema,
  queries: ["src/same-type-other-fields.gql"],
  src,
  dest
});

graphqlToElm(`${name} other-type-same-fields`, {
  schema,
  queries: ["src/other-type-same-fields.gql"],
  src,
  dest
});

graphqlToElm(`${name} other-type-other-fields`, {
  schema,
  queries: ["src/other-type-other-fields.gql"],
  src,
  dest
});

// TODO
// - big objects (more than 8 fields, needs andMap)
// - resursive decoding? (using lazy)

compareDirs("generated-output", "expected-output");
