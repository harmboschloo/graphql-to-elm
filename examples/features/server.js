// @ts-check

const { readFileSync } = require("fs");
const express = require("express");
const { ApolloServer, gql } = require("apollo-server-express");

const typeDefs = gql(readFileSync("src/schema.gql", "utf8"));
const server = new ApolloServer({ typeDefs, mocks: true });
const app = express();
server.applyMiddleware({ app });
app.use(express.static(__dirname));
app.listen(3000);

console.log("example    : http://localhost:3000");
console.log("playground : http://localhost:3000/graphql");
