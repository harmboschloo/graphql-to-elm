module GraphQL.Http exposing
    ( Batch
    , Errors
    , Mutation
    , Query
    , Response
    , postBatch
    , postMutation
    , postQuery
    , send
    , sendBatch
    )

import GraphQL.Batch
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


type alias Batch a =
    GraphQL.Batch.Batch Errors a


type alias Response a =
    GraphQL.Response.Response Errors a


endpoint : String
endpoint =
    "/graphql"


postQuery : Query a -> Http.Request (Response a)
postQuery =
    GraphQL.Http.Basic.postQuery endpoint


postMutation : Mutation a -> Http.Request (Response a)
postMutation =
    GraphQL.Http.Basic.postMutation endpoint


postBatch : Batch a -> Http.Request (Result Errors a)
postBatch =
    GraphQL.Http.Basic.postBatch endpoint


send : (Result String a -> msg) -> Http.Request (Response a) -> Cmd msg
send resultMsg =
    Http.send (mapResult >> resultMsg)


sendBatch : (Result String a -> msg) -> Http.Request (Result Errors a) -> Cmd msg
sendBatch resultMsg =
    Http.send (mapBatchResult >> resultMsg)


mapResult : Result Http.Error (Response a) -> Result String a
mapResult =
    Result.map GraphQL.Response.toResult >> mapBatchResult


mapBatchResult : Result Http.Error (Result Errors a) -> Result String a
mapBatchResult httpResult =
    case httpResult of
        Err error ->
            Err (httpErrorToString error)

        Ok graphqlResult ->
            case graphqlResult of
                Err [] ->
                    Err "GraphQL something went wrong"

                Err (head :: _) ->
                    Err head.message

                Ok data ->
                    Ok data


httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "Http bad url: " ++ url

        Http.Timeout ->
            "Http timeout"

        Http.NetworkError ->
            "Http network error"

        Http.BadStatus response ->
            "Http bad status: " ++ response.status.message

        Http.BadPayload message _ ->
            "Http bad payload: : " ++ message
