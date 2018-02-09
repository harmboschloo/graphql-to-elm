import { readFileSync } from "fs";
import express = require("express");
import bodyParser = require("body-parser");
import { graphqlExpress, graphiqlExpress } from "graphql-server-express";
import { makeExecutableSchema, addMockFunctionsToSchema } from "graphql-tools";
import { schemas } from "./generated/schemas";

const app = express();

Object.keys(schemas).forEach(id => {
  const typeDefs = readFileSync(schemas[id], "utf8");
  const schema = makeExecutableSchema({ typeDefs });
  addMockFunctionsToSchema({ schema });
  const endpointURL = `/graphql/${id}`;
  app.use(endpointURL, bodyParser.json(), graphqlExpress({ schema }));
  app.use(`/graphiql/${id}`, graphiqlExpress({ endpointURL }));
});

app.use(express.static(__dirname));

app.listen(3000);

console.log("server started on http://localhost:3000");
