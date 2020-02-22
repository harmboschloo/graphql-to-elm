module GraphQL.Http exposing (getQuery, postQuery, postMutation, postBatch, postPlainBatch)

{-| Some basic helper functions for creating GraphQL http requests.

@docs getQuery, postQuery, postMutation, postBatch, postPlainBatch

-}

import GraphQL.Batch as Batch
import GraphQL.Operation as Operation exposing (Mutation, Operation, Query)
import GraphQL.PlainBatch as PlainBatch
import GraphQL.Response as Response exposing (Response)
import Http
import Url.Builder


{-|

    getQuery url operation =
        Http.get
            (url ++ Url.Builder.toQuery (Operation.queryParameters operation))
            (Response.decoder operation)

-}
getQuery : String -> Operation Query e a -> Http.Request (Response e a)
getQuery url operation =
    Http.get
        (url ++ Url.Builder.toQuery (Operation.queryParameters operation))
        (Response.decoder operation)


{-|

    postQuery url query =
        Http.post
            url
            (Http.jsonBody <| Operation.encode query)
            (Response.decoder query)

-}
postQuery : String -> Operation Query e a -> Http.Request (Response e a)
postQuery =
    postOperation


{-|

    postMutation url mutation =
        Http.post
            url
            (Http.jsonBody <| Operation.encode mutation)
            (Response.decoder mutation)

-}
postMutation : String -> Operation Mutation e a -> Http.Request (Response e a)
postMutation =
    postOperation


postOperation : String -> Operation t e a -> Http.Request (Response e a)
postOperation url operation =
    Http.post
        url
        (Http.jsonBody <| Operation.encode operation)
        (Response.decoder operation)


{-|

    postBatch url batch =
        Http.post
            url
            (Http.jsonBody <| Batch.encode batch)
            (Batch.decoder batch)

-}
postBatch : String -> Batch.Batch e a -> Http.Request (Result e a)
postBatch url batch =
    Http.post
        url
        (Http.jsonBody <| Batch.encode batch)
        (Batch.decoder batch)


{-|

    postPlainBatch url batch =
        Http.post
            url
            (Http.jsonBody <| PlainBatch.encode batch)
            (PlainBatch.decoder batch)

-}
postPlainBatch : String -> PlainBatch.Batch a -> Http.Request a
postPlainBatch url batch =
    Http.post
        url
        (Http.jsonBody <| PlainBatch.encode batch)
        (PlainBatch.decoder batch)
