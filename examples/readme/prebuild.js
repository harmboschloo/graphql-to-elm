// @ts-check

const { graphqlToElm } = require("../..");

graphqlToElm({
  schema: "./src/mySchema.gql",
  queries: ["./src/myQuery.gql"],
  src: "./src",
  dest: "./src-generated",
}).catch((error) => {
  console.error(error);
  process.exit(1);
});
