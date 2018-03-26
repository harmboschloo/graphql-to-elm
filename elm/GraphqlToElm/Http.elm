module GraphqlToElm.Http
    exposing
        ( Request
        , Error
        , getQuery
        , postQuery
        , postMutation
        , send
        )

{-| Some basic functions for sending GraphQL http requests.

@docs Request, Error, getQuery, postQuery, postMutation, send

-}

import Http
import GraphqlToElm.Response as Response exposing (Response)
import GraphqlToElm.Operation as Operation exposing (Operation, Query, Mutation)
import GraphqlToElm.Helpers.Url as Url


{-| -}
type alias Request a =
    Http.Request a


{-| -}
type alias Error =
    Http.Error


{-| -}
getQuery : String -> Operation Query e a -> Request (Response e a)
getQuery url operation =
    Http.get
        (Url.withParameters url <| Operation.encodeParameters operation)
        (Response.decoder operation)


{-| -}
postQuery : String -> Operation Query e a -> Request (Response e a)
postQuery =
    postAny


{-| -}
postMutation : String -> Operation Mutation e a -> Request (Response e a)
postMutation =
    postAny


postAny : String -> Operation t e a -> Request (Response e a)
postAny url operation =
    Http.post
        url
        (Http.jsonBody <| Operation.encode operation)
        (Response.decoder operation)


{-| -}
send :
    (Result Http.Error (Response e a) -> msg)
    -> Request (Response e a)
    -> Cmd msg
send =
    Http.send
