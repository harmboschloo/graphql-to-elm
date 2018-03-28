const glob = require("glob");
const { graphqlToElm } = require("graphql-to-elm");

const schema = "./src/schema.gql";
const queries = glob.sync("./src/*/**/*.gql");
const src = "./src";
const dest = "./src-generated";

graphqlToElm({
  schema,
  queries,
  src,
  dest
});
