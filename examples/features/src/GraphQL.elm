module GraphQL
    exposing
        ( Errors
        , Query
        , Mutation
        , Batch
        , Response
        , postQuery
        , postMutation
        , postBatch
        , send
        , sendBatch
        )

import Http
import GraphqlToElm.Batch
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


type alias Batch a =
    GraphqlToElm.Batch.Batch Errors a


type alias Response a =
    GraphqlToElm.Response.Response Errors a


endpoint : String
endpoint =
    "/graphql"


postQuery : Query a -> Http.Request (Response a)
postQuery =
    GraphqlToElm.Http.postQuery endpoint


postMutation : Mutation a -> Http.Request (Response a)
postMutation =
    GraphqlToElm.Http.postMutation endpoint


postBatch : Batch a -> Http.Request (Result Errors a)
postBatch =
    GraphqlToElm.Http.postBatch endpoint


send : (Result String a -> msg) -> Http.Request (Response a) -> Cmd msg
send resultMsg =
    Http.send (mapResult >> resultMsg)


sendBatch : (Result String a -> msg) -> Http.Request (Result Errors a) -> Cmd msg
sendBatch resultMsg =
    Http.send (mapBatchResult >> resultMsg)


mapResult : Result Http.Error (Response a) -> Result String a
mapResult =
    Result.map (GraphqlToElm.Response.toResult) >> mapBatchResult


mapBatchResult : Result Http.Error (Result Errors a) -> Result String a
mapBatchResult result =
    case result of
        Err error ->
            Err (httpErrorToString error)

        Ok result ->
            case result of
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
