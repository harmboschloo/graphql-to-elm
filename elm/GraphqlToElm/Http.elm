module GraphqlToElm.Http
    exposing
        ( Request
        , Error
        , get
        , post
        , send
        )

import Http
import GraphqlToElm.Response as Response exposing (Response)
import GraphqlToElm.Operation as Operation exposing (Operation)
import GraphqlToElm.Helpers.Url as Url
 

type alias Request a =
    Http.Request a


type alias Error =
    Http.Error


get : String -> Operation e a -> Request (Response e a)
get url operation =
    Http.get
        (Url.withParameters url <| Operation.encodeParameters operation)
        (Response.decoder operation)


post : String -> Operation e a -> Request (Response e a)
post url operation =
    Http.post
        url
        (Http.jsonBody <| Operation.encode operation)
        (Response.decoder operation)


send :
    (Result Http.Error (Response e a) -> msg)
    -> Request (Response e a)
    -> Cmd msg
send =
    Http.send
