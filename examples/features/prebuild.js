// @ts-check

const glob = require("glob");
const { graphqlToElm } = require("graphql-to-elm");

graphqlToElm({
  schema: "./src/schema.gql",
  queries: glob.sync("./src/Queries/*.gql"),
  enumEncoders: {
    Language: {
      type: "Language.Language",
      encoder: "Language.encode"
    }
  },
  src: "./src",
  dest: "./src-generated"
});
