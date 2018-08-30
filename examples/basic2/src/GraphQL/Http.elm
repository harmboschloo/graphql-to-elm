module GraphQL.Http exposing
    ( Errors
    , Mutation
    , Query
    , Request
    , Response
    , getQuery
    , postMutation
    , send
    )

import GraphQL.Errors
import GraphQL.Http.Basic
import GraphQL.Operation
import GraphQL.Response
import Http


type alias Errors =
    GraphQL.Errors.Errors


type alias Query a =
    GraphQL.Operation.Operation GraphQL.Operation.Query Errors a


type alias Mutation a =
    GraphQL.Operation.Operation GraphQL.Operation.Mutation Errors a


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


postMutation : Mutation a -> Request a
postMutation =
    GraphQL.Http.Basic.postMutation endpoint


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
                GraphQL.Response.Data data ->
                    Ok data

                GraphQL.Response.Errors [] _ ->
                    Err "GraphQL something went wrong"

                GraphQL.Response.Errors (first :: rest) _ ->
                    Err first.message
