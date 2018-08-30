module NullableEnum exposing
    ( Query
    , Response
    , query
    )

import Data.Binary
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
binaryOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { binaryOrNull : Maybe.Maybe Data.Binary.Binary
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "binaryOrNull" (Json.Decode.nullable Data.Binary.decoder))
