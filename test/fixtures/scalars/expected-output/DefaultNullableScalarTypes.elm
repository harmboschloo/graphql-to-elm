module DefaultNullableScalarTypes exposing
    ( Query
    , Response
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
intOrNull
floatOrNull
stringOrNull
booleanOrNull
idOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


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
