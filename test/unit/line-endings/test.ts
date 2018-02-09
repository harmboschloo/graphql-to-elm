import { graphqlToElm, compareDirs } from "../../lib";

const name = "line endings";
const schema = "src/schema.gql";
const src = "src";
const dest = "generated-output";

graphqlToElm(`${name} lf`, {
  schema,
  queries: ["src/lf.gql"],
  src,
  dest
});

graphqlToElm(`${name} crlf`, {
  schema,
  queries: ["src/crlf.gql"],
  src,
  dest
});

compareDirs("generated-output", "expected-output");
