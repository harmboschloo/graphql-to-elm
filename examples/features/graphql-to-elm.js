// @ts-check

const rimraf = require("rimraf");
const glob = require("glob");
const { graphqlToElm } = require("../..");

const options = {
  schema: "./src/schema.gql",
  queries: glob.sync("./src/*/**/*.gql"),
  enumEncoders: {
    Language: {
      type: "Language.Language",
      encoder: "Language.encode"
    }
  },
  src: "./src",
  dest: "./src-generated"
};

// remove previously generated files
rimraf.sync(options.dest);

// generate new elm files
graphqlToElm(options);
