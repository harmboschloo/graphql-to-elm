import { graphqlToElm } from "../..";
import { compareDirs, makeElm, testPage } from "../utils";

graphqlToElm({
  schema: "src/schema.gql",
  queries: ["src/query.gql"],
  src: "src",
  dest: "generated-output"
});

compareDirs("generated-output", "expected-output");

makeElm("generated-test", "Main.elm");

testPage("generated-test", "index.html");
