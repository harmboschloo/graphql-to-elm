module GraphqlToElm.Http
    exposing
        ( Request
        , Response
        , Error(GraphqlError, HttpError)
        , get
        , post
        , send
        )

import Http
import GraphqlToElm.Graphql.Response as GraphqlResponse
import GraphqlToElm.Graphql.Operation as Operation exposing (Operation)
import GraphqlToElm.Optional exposing (Optional)
import GraphqlToElm.Helpers.Url as Url


type alias Request e a =
    Http.Request (GraphqlResponse.Response e a)


type alias Response e a =
    Result (Error e a) a


type Error e a
    = GraphqlError e (Optional a)
    | HttpError Http.Error


get : String -> Operation e a -> Request e a
get url operation =
    Http.get
        (Url.withParameters url <| Operation.encodeParameters operation)
        (GraphqlResponse.decoder operation)


post : String -> Operation e a -> Request e a
post url operation =
    Http.post
        url
        (Http.jsonBody <| Operation.encode operation)
        (GraphqlResponse.decoder operation)


send : (Response e a -> msg) -> Request e a -> Cmd msg
send responseMsg request =
    Http.send (toResponse >> responseMsg) request


toResponse : Result Http.Error (GraphqlResponse.Response e a) -> Response e a
toResponse result =
    case result of
        Err error ->
            Err (HttpError error)

        Ok (GraphqlResponse.Errors errors data) ->
            Err (GraphqlError errors data)

        Ok (GraphqlResponse.Data data) ->
            Ok data
