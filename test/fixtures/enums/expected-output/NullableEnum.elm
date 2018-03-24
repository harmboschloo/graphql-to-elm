module NullableEnum
    exposing
        ( Query
        , query
        )

import Data.Binary
import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
        """{
binaryOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { binaryOrNull : Maybe.Maybe Data.Binary.Binary
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "binaryOrNull" (Json.Decode.nullable Data.Binary.decoder))
