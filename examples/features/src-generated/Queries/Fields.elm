module Queries.Fields
    exposing
        ( Response
        , Query
        , User
        , Message
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
user {
name
email
}
lastMessage {
message
}
messages {
message
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { user : User
    , lastMessage : Maybe.Maybe Message
    , messages : List Message
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map3 Query
        (Json.Decode.field "user" userDecoder)
        (Json.Decode.field "lastMessage" (Json.Decode.nullable messageDecoder))
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))


type alias User =
    { name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias Message =
    { message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map Message
        (Json.Decode.field "message" Json.Decode.string)
