module OtherTypeSameFields
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
    GraphqlToElm.Operation.query
        """{
me {
name
email
}
you {
name
email
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { me : Person
    , you : Person2
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "me" personDecoder)
        (Json.Decode.field "you" person2Decoder)


type alias Person =
    { name : String
    , email : Maybe.Maybe String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))


type alias Person2 =
    { name : String
    , email : Maybe.Maybe String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
