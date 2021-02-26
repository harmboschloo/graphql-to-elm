// @ts-check

const { readFileSync } = require("fs");
const express = require("express");
const { ApolloServer, gql } = require("apollo-server-express");

const messages = [{ message: "Hello" }, { message: "World" }];

const typeDefs = gql(readFileSync("src/schema.gql", "utf8"));

const resolvers = {
  Query: {
    messages: () => messages,
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
});

const app = express();
server.applyMiddleware({ app });
app.use(express.static(__dirname));
app.listen(3000);

console.log("example    : http://localhost:3000");
console.log("playground : http://localhost:3000/graphql");
