module Recursive exposing
    ( Comment
    , Comment2
    , Comment3
    , Comment4
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
comments {
message
responses {
message
responses {
message
responses {
message
}
}
}
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { comments : List Comment4
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "comments" (Json.Decode.list comment4Decoder))


type alias Comment4 =
    { message : String
    , responses : List Comment3
    }


comment4Decoder : Json.Decode.Decoder Comment4
comment4Decoder =
    Json.Decode.map2 Comment4
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list comment3Decoder))


type alias Comment3 =
    { message : String
    , responses : List Comment2
    }


comment3Decoder : Json.Decode.Decoder Comment3
comment3Decoder =
    Json.Decode.map2 Comment3
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list comment2Decoder))


type alias Comment2 =
    { message : String
    , responses : List Comment
    }


comment2Decoder : Json.Decode.Decoder Comment2
comment2Decoder =
    Json.Decode.map2 Comment2
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list commentDecoder))


type alias Comment =
    { message : String
    }


commentDecoder : Json.Decode.Decoder Comment
commentDecoder =
    Json.Decode.map Comment
        (Json.Decode.field "message" Json.Decode.string)
