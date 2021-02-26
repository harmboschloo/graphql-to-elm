// @ts-check

const { graphqlToElm } = require("../..");

graphqlToElm({
  schema: "./src/schema.gql",
  queries: ["./src/Queries/Messages.gql"],
  src: "./src",
  dest: "./src-generated",
}).catch((error) => {
  console.error(error);
  process.exit(1);
});
