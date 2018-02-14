import { readFileSync } from "fs";
import express = require("express");
import bodyParser = require("body-parser");
import { GraphQLScalarType } from "graphql";
import { graphqlExpress, graphiqlExpress } from "graphql-server-express";
import { makeExecutableSchema, addMockFunctionsToSchema } from "graphql-tools";
import { schemas } from "./generated/schemas";

const app = express();

const dateScalar = new GraphQLScalarType({
  name: "Date",
  serialize: value => value,
  parseValue: value => value,
  parseLiteral: ast => (ast.kind == "StringValue" ? ast.value : "")
});

Object.keys(schemas).forEach(id => {
  const typeDefs = readFileSync(schemas[id], "utf8");
  let resolvers = {};
  let mocks = {};
  if (typeDefs.includes("scalar Date")) {
    resolvers["Date"] = dateScalar;
    mocks["Date"] = () => "Wed, 14 Feb 2018 21:27:07 GMT";
  }
  const schema = makeExecutableSchema({ typeDefs, resolvers });
  addMockFunctionsToSchema({ schema, mocks });
  const endpointURL = `/graphql/${id}`;
  app.use(endpointURL, bodyParser.json(), graphqlExpress({ schema }));
  app.use(`/graphiql/${id}`, graphiqlExpress({ endpointURL }));
});

app.use(express.static(`${__dirname}/generated`));

app.listen(3000);

console.log("server started on http://localhost:3000");
