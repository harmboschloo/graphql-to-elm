module Batch.Queries
    exposing
        ( UserResponse
        , UserQuery
        , User
        , MessagesResponse
        , MessagesQuery
        , Message
        , user
        , messages
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


user : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors UserQuery
user =
    GraphqlToElm.Operation.withQuery
        """query User {
user {
id
name
email
}
}"""
        Maybe.Nothing
        userQueryDecoder
        GraphqlToElm.Errors.decoder


messages : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors MessagesQuery
messages =
    GraphqlToElm.Operation.withQuery
        """query Messages {
messages {
id
from {
id
name
email
}
message
}
}"""
        Maybe.Nothing
        messagesQueryDecoder
        GraphqlToElm.Errors.decoder


type alias UserResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors UserQuery


type alias MessagesResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors MessagesQuery


type alias UserQuery =
    { user : User
    }


userQueryDecoder : Json.Decode.Decoder UserQuery
userQueryDecoder =
    Json.Decode.map UserQuery
        (Json.Decode.field "user" userDecoder)


type alias User =
    { id : String
    , name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias MessagesQuery =
    { messages : List Message
    }


messagesQueryDecoder : Json.Decode.Decoder MessagesQuery
messagesQueryDecoder =
    Json.Decode.map MessagesQuery
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))


type alias Message =
    { id : String
    , from : User
    , message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map3 Message
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "from" userDecoder)
        (Json.Decode.field "message" Json.Decode.string)
