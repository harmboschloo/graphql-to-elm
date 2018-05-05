module GraphQL
    exposing
        ( Errors
        , Query
        , Mutation
        , Response
        , Request
        , getQuery
        , postMutation
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


type alias Mutation a =
    GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation Errors a


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


postMutation : Mutation a -> Request a
postMutation =
    GraphqlToElm.Http.postMutation endpoint


send : (Result String a -> msg) -> Request a -> Cmd msg
send resultMsg =
    Http.send (mapResult >> resultMsg)


mapResult : Result Http.Error (Response a) -> Result String a
mapResult result =
    case result of
        Err error ->
            case error of
                Http.BadUrl url ->
                    Err ("Http bad url: " ++ url)

                Http.Timeout ->
                    Err "Http timeout"

                Http.NetworkError ->
                    Err "Http network error"

                Http.BadStatus response ->
                    Err ("Http bad status: " ++ response.status.message)

                Http.BadPayload message _ ->
                    Err ("Http bad payload: : " ++ message)

        Ok response ->
            case response of
                GraphqlToElm.Response.Data data ->
                    Ok data

                GraphqlToElm.Response.Errors [] _ ->
                    Err "GraphQL something went wrong"

                GraphqlToElm.Response.Errors (first :: rest) _ ->
                    Err first.message
