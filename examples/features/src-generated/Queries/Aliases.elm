module Queries.Aliases
    exposing
        ( Response
        , Query
        , query
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
en: translation(id: "hello.world", language: EN)
nl: translation(id: "hello.world", language: NL)
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { en : Maybe.Maybe String
    , nl : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "en" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "nl" (Json.Decode.nullable Json.Decode.string))
