// @ts-check

const { readFileSync } = require("fs");
const express = require("express");
const { ApolloServer, gql } = require("apollo-server-express");

const messages = [];

const typeDefs = gql(readFileSync("src/schema.gql", "utf8"));

const resolvers = {
  Query: {
    messages: () => messages,
  },

  Mutation: {
    postMessage: (obj, args) => {
      if (!args.message || args.message.trim() === "") {
        return { error: "message cannot be empty" };
      }

      const message = {
        id: messages.length,
        message: args.message,
      };
      messages.push(message);
      return message;
    },
  },

  PostMessageResponse: {
    __resolveType: (data) => (data.error ? "MutationError" : "Message"),
  },
};

const server = new ApolloServer({
  typeDefs,
  resolvers,
});

const app = express();
server.start().then(() => {
  server.applyMiddleware({ app });
  app.use(express.static(__dirname));
  app.listen(3000);

  console.log("example    : http://localhost:3000");
  console.log("playground : http://localhost:3000/graphql");
});
