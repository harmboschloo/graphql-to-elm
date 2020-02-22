module GraphQL.Http exposing
    ( getQuery
    , postBatch
    , postMutation
    , postPlainBatch
    , postQuery
    )

import GraphQL.Batch as Batch
import GraphQL.Operation as Operation exposing (Mutation, Operation, Query)
import GraphQL.PlainBatch as PlainBatch
import GraphQL.Response as Response exposing (Response)
import Http
import Url.Builder


getQuery : String -> Operation Query e a -> (Result Http.Error (Response e a) -> msg) -> Cmd msg
getQuery baseUrl operation msg =
    Http.get
        { url = getQueryUrl baseUrl operation
        , expect = expectOperationResponse msg operation
        }


getQueryUrl : String -> Operation Query e a -> String
getQueryUrl baseUrl operation =
    baseUrl ++ Url.Builder.toQuery (Operation.queryParameters operation)


postQuery : String -> Operation Query e a -> (Result Http.Error (Response e a) -> msg) -> Cmd msg
postQuery =
    postOperation


postMutation : String -> Operation Mutation e a -> (Result Http.Error (Response e a) -> msg) -> Cmd msg
postMutation =
    postOperation


postOperation : String -> Operation t e a -> (Result Http.Error (Response e a) -> msg) -> Cmd msg
postOperation url operation msg =
    Http.post
        { url = url
        , body = Http.jsonBody (Operation.encode operation)
        , expect = expectOperationResponse msg operation
        }


expectOperationResponse : (Result Http.Error (Response e a) -> msg) -> Operation t e a -> Http.Expect msg
expectOperationResponse msg operation =
    Http.expectJson msg (Response.decoder operation)


postBatch : String -> Batch.Batch e a -> (Result Http.Error (Result e a) -> msg) -> Cmd msg
postBatch url batch msg =
    Http.post
        { url = url
        , body = Http.jsonBody (Batch.encode batch)
        , expect = Http.expectJson msg (Batch.decoder batch)
        }


postPlainBatch : String -> PlainBatch.Batch a -> (Result Http.Error a -> msg) -> Cmd msg
postPlainBatch url batch msg =
    Http.post
        { url = url
        , body = Http.jsonBody (PlainBatch.encode batch)
        , expect = Http.expectJson msg (PlainBatch.decoder batch)
        }
