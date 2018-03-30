module SameTypeOtherFields
    exposing
        ( Response
        , Query
        , Person
        , Person2
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
        """{
i {
name
age
}
me {
email
age
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { i : Person
    , me : Person2
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" person2Decoder)


type alias Person =
    { name : String
    , age : Maybe.Maybe Int
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias Person2 =
    { email : Maybe.Maybe String
    , age : Maybe.Maybe Int
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
