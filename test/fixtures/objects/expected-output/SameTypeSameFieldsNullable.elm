module SameTypeSameFieldsNullable
    exposing
        ( Query
        , Person2
        , query
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
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
        GraphqlToElm.Graphql.Errors.decoder


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
