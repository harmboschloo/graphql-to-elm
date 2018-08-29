import { testGen } from "graphql-to-elm-test-gen";
import { Config, getConfig } from "graphql-to-elm-test-config";

const config: Config = getConfig();

testGen({ ...config, update: true });
