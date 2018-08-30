import { readFileSync } from "fs";
import { resolve } from "path";

export type Config = {
  graphqlVersion: "0.12" | "0.13";
};

export const getConfig = (): Config => {
  const config = JSON.parse(
    readFileSync(resolve(__dirname, "../../package.json"), "utf8")
  );

  const graphqlVersion =
    config.devDependencies.graphql.indexOf("0.12") === 0 ? "0.12" : "0.13";
  return { graphqlVersion };
};
