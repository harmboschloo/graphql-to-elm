module Enum
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
    GraphqlToElm.Operation.query
        """{
binary
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { binary : Data.Binary.Binary
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "binary" Data.Binary.decoder)
