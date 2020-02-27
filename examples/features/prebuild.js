// @ts-check

const glob = require("glob");
const { graphqlToElm } = require("../..");

graphqlToElm({
  schema: "./src/schema.gql",
  queries: glob.sync("./src/Queries/*.gql"),
  src: "./src",
  dest: "./src-generated"
}).catch(error => {
  console.error(error);
  process.exit(1);
});
