module GraphQL.Http exposing
    ( post
    , postBatch
    )

import GraphQL.Batch exposing (Batch)
import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation)
import GraphQL.Response exposing (Response)
import Http


post : Operation t Errors a -> (Result String a -> msg) -> Cmd msg
post operation msg =
    Http.post
        { url = "/graphql"
        , body = Http.jsonBody (GraphQL.Operation.encode operation)
        , expect = Http.expectJson (mapResult >> msg) (GraphQL.Response.decoder operation)
        }


mapResult : Result Http.Error (Response Errors a) -> Result String a
mapResult =
    Result.map GraphQL.Response.toResult >> mapBatchResult


postBatch : Batch Errors a -> (Result String a -> msg) -> Cmd msg
postBatch batch msg =
    Http.post
        { url = "/graphql"
        , body = Http.jsonBody (GraphQL.Batch.encode batch)
        , expect = Http.expectJson (mapBatchResult >> msg) (GraphQL.Batch.decoder batch)
        }


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

        Http.BadStatus status ->
            "Http bad status: " ++ String.fromInt status

        Http.BadBody body ->
            "Http bad body: : " ++ body
