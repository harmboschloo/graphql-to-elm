module DefaultNullableScalarTypes
    exposing
        ( Query
        , query
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
        """{
intOrNull
floatOrNull
stringOrNull
booleanOrNull
idOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Query =
    { intOrNull : Maybe.Maybe Int
    , floatOrNull : Maybe.Maybe Float
    , stringOrNull : Maybe.Maybe String
    , booleanOrNull : Maybe.Maybe Bool
    , idOrNull : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map5 Query
        (Json.Decode.field "intOrNull" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "floatOrNull" (Json.Decode.nullable Json.Decode.float))
        (Json.Decode.field "stringOrNull" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "booleanOrNull" (Json.Decode.nullable Json.Decode.bool))
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Json.Decode.string))
