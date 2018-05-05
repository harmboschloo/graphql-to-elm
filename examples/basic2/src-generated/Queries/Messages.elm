module Queries.Messages
    exposing
        ( MessagesResponse
        , MessagesQuery
        , Message
        , PostMessageResponse2
        , PostMessageVariables
        , PostMessageMutation
        , PostMessageResponse(..)
        , MutationError
        , messages
        , postMessage
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


messages : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors MessagesQuery
messages =
    GraphqlToElm.Operation.withQuery
        """query Messages {
messages {
id
message
}
}"""
        Maybe.Nothing
        messagesQueryDecoder
        GraphqlToElm.Errors.decoder


postMessage : PostMessageVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors PostMessageMutation
postMessage variables =
    GraphqlToElm.Operation.withQuery
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
        GraphqlToElm.Errors.decoder


type alias MessagesResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors MessagesQuery


type alias PostMessageResponse2 =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors PostMessageMutation


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
