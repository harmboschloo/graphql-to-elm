import { testBrowser } from "graphql-to-elm-test-browser";
import { Config, getConfig } from "graphql-to-elm-test-config";

const config: Config = getConfig();

testBrowser(config);
