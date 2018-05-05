module Queries.Aliases
    exposing
        ( Response
        , Query
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
        """{
en: translation(id: "hello.world", language: EN)
nl: translation(id: "hello.world", language: NL)
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { en : Maybe.Maybe String
    , nl : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "en" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "nl" (Json.Decode.nullable Json.Decode.string))
