module GraphqlToElm.Http
    exposing
        ( getQuery
        , postQuery
        , postMutation
        , postBatch
        , postPlainBatch
        )

{-| Some basic helper functions for creating GraphQL http requests.

@docs getQuery, postQuery, postMutation, postBatch, postPlainBatch

-}

import Http
import GraphqlToElm.Operation as Operation exposing (Operation, Query, Mutation)
import GraphqlToElm.Response as Response exposing (Response)
import GraphqlToElm.Batch as Batch
import GraphqlToElm.PlainBatch as PlainBatch
import GraphqlToElm.Helpers.Url as Url


{-|
    getQuery url operation =
        Http.get
            (UrlHelper.withParameters url <| Operation.encodeParameters operation)
            (Response.decoder operation)

    For `UrlHelper` see `GraphqlToElm.Helpers.Url`.
 -}
getQuery : String -> Operation Query e a -> Http.Request (Response e a)
getQuery url operation =
    Http.get
        (Url.withParameters url <| Operation.encodeParameters operation)
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
