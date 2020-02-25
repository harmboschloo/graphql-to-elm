module GraphQL.Http exposing (get)

import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation, Query)
import GraphQL.Response exposing (Response)
import Http
import Url.Builder


get : Operation Query Errors a -> (Result Http.Error (Response Errors a) -> msg) -> Cmd msg
get operation msg =
    Http.get
        { url = Url.Builder.absolute [ "graphql" ] (GraphQL.Operation.queryParameters operation)
        , expect = Http.expectJson msg (GraphQL.Response.decoder operation)
        }
