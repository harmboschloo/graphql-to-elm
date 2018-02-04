import { graphqlToElm } from "../..";

graphqlToElm({
  schema: "src/schema.gql",
  queries: ["src/query.gql"],
  src: "src",
  dest: "generated-output"
});
