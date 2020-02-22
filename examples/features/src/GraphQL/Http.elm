module GraphQL.Http exposing
    ( postBatch
    , postOperation
    , send
    , sendBatch
    )

import GraphQL.Batch exposing (Batch)
import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation)
import GraphQL.Response exposing (Response)
import Http


postOperation : Operation t Errors a -> Http.Request (Response Errors a)
postOperation operation =
    Http.post
        "/graphql"
        (Http.jsonBody <| GraphQL.Operation.encode operation)
        (GraphQL.Response.decoder operation)


postBatch : Batch Errors a -> Http.Request (Result Errors a)
postBatch batch =
    Http.post
        "/graphql"
        (Http.jsonBody <| GraphQL.Batch.encode batch)
        (GraphQL.Batch.decoder batch)


send : (Result String a -> msg) -> Http.Request (Response Errors a) -> Cmd msg
send resultMsg =
    Http.send (mapResult >> resultMsg)


sendBatch : (Result String a -> msg) -> Http.Request (Result Errors a) -> Cmd msg
sendBatch resultMsg =
    Http.send (mapBatchResult >> resultMsg)


mapResult : Result Http.Error (Response Errors a) -> Result String a
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
