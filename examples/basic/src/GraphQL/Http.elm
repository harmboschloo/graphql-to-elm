module GraphQL.Http exposing (getQuery, send)

import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation, Query)
import GraphQL.Response exposing (Response)
import Http
import Url.Builder


getQuery : Operation Query Errors a -> Http.Request (Response Errors a)
getQuery operation =
    Http.get
        (Url.Builder.absolute [ "graphql" ] (GraphQL.Operation.queryParameters operation))
        (GraphQL.Response.decoder operation)


send : (Result Http.Error (Response Errors a) -> msg) -> Http.Request (Response Errors a) -> Cmd msg
send =
    Http.send
