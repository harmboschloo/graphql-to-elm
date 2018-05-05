module Fields.Queries
    exposing
        ( BasicResponse
        , BasicQuery
        , User
        , MaybeResponse
        , MaybeQuery
        , Message
        , ListResponse
        , ListQuery
        , basic
        , maybe
        , list
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


basic : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors BasicQuery
basic =
    GraphqlToElm.Operation.withQuery
        """query Basic {
user {
name
email
}
}"""
        Maybe.Nothing
        basicQueryDecoder
        GraphqlToElm.Errors.decoder


maybe : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors MaybeQuery
maybe =
    GraphqlToElm.Operation.withQuery
        """query Maybe {
lastMessage {
message
}
}"""
        Maybe.Nothing
        maybeQueryDecoder
        GraphqlToElm.Errors.decoder


list : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors ListQuery
list =
    GraphqlToElm.Operation.withQuery
        """query List {
messages {
message
}
}"""
        Maybe.Nothing
        listQueryDecoder
        GraphqlToElm.Errors.decoder


type alias BasicResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors BasicQuery


type alias MaybeResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors MaybeQuery


type alias ListResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors ListQuery


type alias BasicQuery =
    { user : User
    }


basicQueryDecoder : Json.Decode.Decoder BasicQuery
basicQueryDecoder =
    Json.Decode.map BasicQuery
        (Json.Decode.field "user" userDecoder)


type alias User =
    { name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias MaybeQuery =
    { lastMessage : Maybe.Maybe Message
    }


maybeQueryDecoder : Json.Decode.Decoder MaybeQuery
maybeQueryDecoder =
    Json.Decode.map MaybeQuery
        (Json.Decode.field "lastMessage" (Json.Decode.nullable messageDecoder))


type alias Message =
    { message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map Message
        (Json.Decode.field "message" Json.Decode.string)


type alias ListQuery =
    { messages : List Message
    }


listQueryDecoder : Json.Decode.Decoder ListQuery
listQueryDecoder =
    Json.Decode.map ListQuery
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))
