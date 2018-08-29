import { testOptions } from "graphql-to-elm-test-options";
import { testGen } from "graphql-to-elm-test-gen";
import { testBrowser } from "graphql-to-elm-test-browser";
import { Config, getConfig } from "graphql-to-elm-test-config";

const config: Config = getConfig();

testOptions();
testGen(config);
if (!process.env.TRAVIS) {
  testBrowser(config);
}
