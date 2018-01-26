import { graphqlToElm } from "..";

graphqlToElm({
  schema: "schema.gql",
  queries: ["query.gql"]
});
