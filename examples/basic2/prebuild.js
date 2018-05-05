const { graphqlToElm } = require("graphql-to-elm");

graphqlToElm({
  schema: "./src/schema.gql",
  queries: ["./src/Queries/Messages.gql"],
  src: "./src",
  dest: "./src-generated"
});
