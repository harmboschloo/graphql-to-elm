module Nested
    exposing
        ( Query
        , Person
        , Person2
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
        """{
i {
name
age
bestFriend {
name
age
email
}
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { i : Person
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "i" personDecoder)


type alias Person =
    { name : String
    , age : Maybe.Maybe Int
    , bestFriend : Maybe.Maybe Person2
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map3 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "bestFriend" (Json.Decode.nullable person2Decoder))


type alias Person2 =
    { name : String
    , age : Maybe.Maybe Int
    , email : Maybe.Maybe String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map3 Person2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
