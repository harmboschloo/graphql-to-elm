// @ts-check

const { readFileSync } = require("fs");
const express = require("express");
const { ApolloServer, gql } = require("apollo-server-express");

const typeDefs = gql(readFileSync("src/mySchema.gql", "utf8"));

const resolvers = {
  Query: {
    user: () => ({ name: "Mario" }),
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
