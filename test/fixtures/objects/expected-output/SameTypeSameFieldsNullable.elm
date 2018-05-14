module SameTypeSameFieldsNullable
    exposing
        ( Response
        , Query
        , Person2
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
you {
email
age
}
youOrNull {
age
email
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { you : Person2
    , youOrNull : Maybe.Maybe Person2
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "you" person2Decoder)
        (Json.Decode.field "youOrNull" (Json.Decode.nullable person2Decoder))


type alias Person2 =
    { email : Maybe.Maybe String
    , age : Maybe.Maybe Int
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
