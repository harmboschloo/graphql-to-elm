const { readFileSync } = require("fs");
const express = require("express");
const bodyParser = require("body-parser");
const { graphqlExpress, graphiqlExpress } = require("apollo-server-express");
const { makeExecutableSchema } = require("graphql-tools");

const messages = [{ message: "Hello" }, { message: "World" }];

const typeDefs = readFileSync("src/schema.gql", "utf8");
const resolvers = {
  Query: {
    messages: () => messages
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
