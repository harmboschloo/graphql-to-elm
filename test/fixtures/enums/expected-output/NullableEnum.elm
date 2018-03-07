module NullableEnum
    exposing
        ( Query
        , query
        )

import Data.Binary
import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
        """{
binaryOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Query =
    { binaryOrNull : Maybe.Maybe Data.Binary.Binary
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "binaryOrNull" (Json.Decode.nullable Data.Binary.decoder))
