module OtherTypeSameFields
    exposing
        ( Query
        , Person
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
        GraphqlToElm.Graphql.Errors.decoder


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
