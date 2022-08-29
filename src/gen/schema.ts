import { GraphQLSchema, buildSchema } from "graphql";
import { SchemaString } from "./options";
import { readFile } from "./utils";

export const getSchemaString = ({
  schema,
  log,
}: {
  schema: string | SchemaString;
  log?: (message: string) => void;
}): Promise<string> => {
  if (typeof schema === "string") {
    log && log(`reading schema ${schema}`);
    return readFile(schema);
  } else {
    log && log("schema from string");
    return Promise.resolve(schema.string);
  }
};

export const processSchemaString = (schemaString: string): GraphQLSchema => {
  try {
    return buildSchema(schemaString);
  } catch (error) {
    throw new Error(`processing schema\n${error}`);
  }
};
