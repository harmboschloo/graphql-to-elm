const rimraf = require("rimraf");
const glob = require("glob");
const { graphqlToElm } = require("../lib");

// configuration
const schema = "./src/schema.gql";
const queries = glob.sync("./src/*/**/*.gql");
const src = "./src";
const dest = "./src-generated";

const enumEncoders = {
  Language: {
    type: "Language.Language",
    encoder: "Language.encode"
  }
};

// remove previously generated files
rimraf.sync(dest);

// generate new elm files
graphqlToElm({
  schema,
  queries,
  enumEncoders,
  src,
  dest
});
