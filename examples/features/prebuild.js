// @ts-check

const glob = require("glob");
const { graphqlToElm } = require("graphql-to-elm");

graphqlToElm({
  schema: "./src/schema.gql",
  queries: glob.sync("./src/Queries/*.gql"),
  src: "./src",
  dest: "./src-generated"
});
