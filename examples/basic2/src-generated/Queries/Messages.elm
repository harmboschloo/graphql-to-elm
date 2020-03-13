module Queries.Messages exposing
    ( Message
    , MessagesQuery
    , MessagesResponse
    , MutationError
    , PostMessageMutation
    , PostMessageResponse(..)
    , PostMessageResponse2
    , PostMessageVariables
    , encodePostMessageVariables
    , messages
    , postMessage
    , postMessageVariablesDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


messages : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors MessagesQuery
messages =
    GraphQL.Operation.withQuery
        """query Messages {
messages {
id
message
}
}"""
        Maybe.Nothing
        messagesQueryDecoder
        GraphQL.Errors.decoder


postMessage : PostMessageVariables -> GraphQL.Operation.Operation GraphQL.Operation.Mutation GraphQL.Errors.Errors PostMessageMutation
postMessage variables =
    GraphQL.Operation.withQuery
        """mutation PostMessage($message: String!) {
postMessage(message: $message) {
... on Message {
id
message
}
... on MutationError {
error
}
}
}"""
        (Maybe.Just <| encodePostMessageVariables variables)
        postMessageMutationDecoder
        GraphQL.Errors.decoder


type alias MessagesResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors MessagesQuery


type alias PostMessageResponse2 =
    GraphQL.Response.Response GraphQL.Errors.Errors PostMessageMutation


type alias MessagesQuery =
    { messages : List Message
    }


messagesQueryDecoder : Json.Decode.Decoder MessagesQuery
messagesQueryDecoder =
    Json.Decode.map MessagesQuery
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))


type alias Message =
    { id : Int
    , message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map2 Message
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "message" Json.Decode.string)


type alias PostMessageVariables =
    { message : String
    }


encodePostMessageVariables : PostMessageVariables -> Json.Encode.Value
encodePostMessageVariables inputs =
    Json.Encode.object
        [ ( "message", Json.Encode.string inputs.message )
        ]


postMessageVariablesDecoder : Json.Decode.Decoder PostMessageVariables
postMessageVariablesDecoder =
    Json.Decode.map PostMessageVariables
        (Json.Decode.field "message" Json.Decode.string)


type alias PostMessageMutation =
    { postMessage : PostMessageResponse
    }


postMessageMutationDecoder : Json.Decode.Decoder PostMessageMutation
postMessageMutationDecoder =
    Json.Decode.map PostMessageMutation
        (Json.Decode.field "postMessage" postMessageResponseDecoder)


type PostMessageResponse
    = OnMessage Message
    | OnMutationError MutationError


postMessageResponseDecoder : Json.Decode.Decoder PostMessageResponse
postMessageResponseDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnMessage messageDecoder
        , Json.Decode.map OnMutationError mutationErrorDecoder
        ]


type alias MutationError =
    { error : String
    }


mutationErrorDecoder : Json.Decode.Decoder MutationError
mutationErrorDecoder =
    Json.Decode.map MutationError
        (Json.Decode.field "error" Json.Decode.string)
