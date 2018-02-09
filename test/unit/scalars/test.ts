import { graphqlToElm, compareDirs } from "../../lib";

graphqlToElm("default scalars types", {
  schema: "src/schema.gql",
  queries: ["src/default-scalar-types.gql"],
  src: "src",
  dest: "generated-output"
});

graphqlToElm("default nullable scalars types", {
  schema: "src/schema.gql",
  queries: ["src/default-nullable-scalar-types.gql"],
  src: "src",
  dest: "generated-output"
});

compareDirs("generated-output", "expected-output");
