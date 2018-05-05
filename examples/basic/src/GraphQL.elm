module GraphQL
    exposing
        ( Errors
        , Query
        , Response
        , Request
        , getQuery
        , send
        )

import Http
import GraphqlToElm.Errors
import GraphqlToElm.Http
import GraphqlToElm.Operation
import GraphqlToElm.Response


type alias Errors =
    GraphqlToElm.Errors.Errors


type alias Query a =
    GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query Errors a


type alias Response a =
    GraphqlToElm.Response.Response Errors a


type alias Request a =
    Http.Request (Response a)


endpoint : String
endpoint =
    "/graphql"


getQuery : Query a -> Request a
getQuery =
    GraphqlToElm.Http.getQuery endpoint


send : (Result Http.Error (Response a) -> msg) -> Request a -> Cmd msg
send =
    Http.send
