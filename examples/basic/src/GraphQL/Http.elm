module GraphQL.Http exposing (Errors, Query, Response, Request, getQuery, send)

import Http
import GraphQL.Errors
import GraphQL.Http.Basic
import GraphQL.Operation
import GraphQL.Response


type alias Errors =
    GraphQL.Errors.Errors


type alias Query a =
    GraphQL.Operation.Operation GraphQL.Operation.Query Errors a


type alias Response a =
    GraphQL.Response.Response Errors a


type alias Request a =
    Http.Request (Response a)


endpoint : String
endpoint =
    "/graphql"


getQuery : Query a -> Request a
getQuery =
    GraphQL.Http.Basic.getQuery endpoint


send : (Result Http.Error (Response a) -> msg) -> Request a -> Cmd msg
send =
    Http.send
