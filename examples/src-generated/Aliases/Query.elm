module Aliases.Query
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
helloWorldEn: translation(id: "hello.world", language: EN)
helloWorldNl: translation(id: "hello.world", language: NL)
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { helloWorldEn : Maybe.Maybe String
    , helloWorldNl : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "helloWorldEn" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "helloWorldNl" (Json.Decode.nullable Json.Decode.string))
