module OtherTypeOtherFields exposing
    ( Dog
    , Person
    , Person2
    , Person22
    , Query
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
i {
dog {
name
}
}
me {
name
}
you {
email
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { i : Person
    , me : Person2
    , you : Person22
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map3 Query
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" person2Decoder)
        (Json.Decode.field "you" person22Decoder)


type alias Person =
    { dog : Maybe.Maybe Dog
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map Person
        (Json.Decode.field "dog" (Json.Decode.nullable dogDecoder))


type alias Dog =
    { name : Maybe.Maybe String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))


type alias Person2 =
    { name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map Person2
        (Json.Decode.field "name" Json.Decode.string)


type alias Person22 =
    { email : Maybe.Maybe String
    }


person22Decoder : Json.Decode.Decoder Person22
person22Decoder =
    Json.Decode.map Person22
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
