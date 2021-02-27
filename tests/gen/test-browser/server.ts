import * as express from "express";
import * as bodyParser from "body-parser";
import { GraphQLScalarType } from "graphql";
import {
  ApolloServer,
  makeExecutableSchema,
  addMockFunctionsToSchema,
} from "apollo-server-express";
import { namedQueries } from "./generated/namedQueries";
import { schemas } from "./generated/schemas";

const app = express();

const timeScalar = new GraphQLScalarType({
  name: "Time",
  serialize: (value) => `${value}`,
  parseValue: (value) => parseInt(value, 10),
  parseLiteral: (ast) =>
    ast.kind == "StringValue" ? parseInt(ast.value, 10) : null,
});

Object.keys(schemas).forEach((id) => {
  const setNamedQuery = (payload: any) => {
    if (payload.operationName && !payload.query) {
      payload.query = namedQueries[`${id}/${payload.operationName}`];
      const split = payload.operationName.split(":");
      if (split.length > 1) {
        payload.operationName = split[1];
      }
    }
  };

  const typeDefs = schemas[id];
  let resolvers: { [type: string]: any } = {};
  let mocks: { [type: string]: any } = {};

  if (typeDefs.includes("scalar Time")) {
    resolvers["Time"] = timeScalar;
    mocks["Time"] = () => Date.now();
  }

  const schema = makeExecutableSchema({
    typeDefs,
    resolvers,
    resolverValidationOptions: { requireResolversForResolveType: false },
  });

  addMockFunctionsToSchema({ schema, mocks });

  const server = new ApolloServer({
    schema,
    introspection: false,
    playground: false,
  });

  const endpointURL = `/graphql/${id}`;

  app.use(endpointURL, bodyParser.json(), (req, _resp, next) => {
    if (Array.isArray(req.body)) {
      req.body.forEach(setNamedQuery);
    } else {
      setNamedQuery(req.body);
      setNamedQuery(req.query);
    }
    next();
  });
  server.applyMiddleware({ app, path: endpointURL });
});

app.use(express.static(`${__dirname}/generated`));

app.listen(3000);

console.log("server started on http://localhost:3000");
