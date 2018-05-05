const { readFileSync } = require("fs");
const express = require("express");
const bodyParser = require("body-parser");
const { graphqlExpress, graphiqlExpress } = require("apollo-server-express");
const { makeExecutableSchema } = require("graphql-tools");

const messages = [];

const typeDefs = readFileSync("src/schema.gql", "utf8");
const resolvers = {
  Query: {
    messages: () => messages
  },

  Mutation: {
    postMessage: (obj, args) => {
      if (!args.message || args.message.trim() === "") {
        return { error: "message cannot be empty" };
      }

      const message = {
        id: messages.length,
        message: args.message
      };
      messages.push(message);
      return message;
    }
  },

  PostMessageResponse: {
    __resolveType: data => (data.error ? "MutationError" : "Message")
  }
};
const schema = makeExecutableSchema({ typeDefs, resolvers });

const app = express();
app.use("/graphql", bodyParser.json(), graphqlExpress({ schema }));
app.use("/graphiql", graphiqlExpress({ endpointURL: "/graphql" }));
app.use(express.static(__dirname));
app.listen(3000);

console.log("example : http://localhost:3000");
console.log("graphql : http://localhost:3000/graphql");
console.log("graphiql: http://localhost:3000/graphiql");
