import { graphqlToElm, compareDirs } from "../../lib";

const name = "lists";
const schema = "src/schema.gql";
const src = "src";
const dest = "generated-output";

graphqlToElm(`${name} of objects`, {
  schema,
  queries: ["src/list-of-objects.gql"],
  src,
  dest
});

graphqlToElm(`${name} of scalars`, {
  schema,
  queries: ["src/list-of-scalars.gql"],
  src,
  dest
});

compareDirs("generated-output", "expected-output");
