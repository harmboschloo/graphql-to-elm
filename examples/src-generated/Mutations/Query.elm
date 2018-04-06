module Mutations.Query
    exposing
        ( PostMessageResponse
        , PostMessageVariables
        , PostMessageMutation
        , postMessage
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


postMessage : PostMessageVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors PostMessageMutation
postMessage variables =
    GraphqlToElm.Operation.withQuery
        """mutation PostMessage($message: String!) {
postMessage(message: $message)
}"""
        (Maybe.Just <| encodePostMessageVariables variables)
        postMessageMutationDecoder
        GraphqlToElm.Errors.decoder


type alias PostMessageResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors PostMessageMutation


type alias PostMessageVariables =
    { message : String
    }


encodePostMessageVariables : PostMessageVariables -> Json.Encode.Value
encodePostMessageVariables inputs =
    Json.Encode.object
        [ ( "message", Json.Encode.string inputs.message )
        ]


type alias PostMessageMutation =
    { postMessage : Maybe.Maybe String
    }


postMessageMutationDecoder : Json.Decode.Decoder PostMessageMutation
postMessageMutationDecoder =
    Json.Decode.map PostMessageMutation
        (Json.Decode.field "postMessage" (Json.Decode.nullable Json.Decode.string))
