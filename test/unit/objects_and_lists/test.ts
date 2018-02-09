import { graphqlToElm, compareDirs } from "../../lib";

graphqlToElm("objects_and_lists", {
  schema: "src/schema.gql",
  queries: ["src/query.gql"],
  src: "src",
  dest: "generated-output"
});

compareDirs("generated-output", "expected-output");
