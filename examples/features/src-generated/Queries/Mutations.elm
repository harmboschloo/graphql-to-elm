module Queries.Mutations exposing
    ( PostMessageMutation
    , PostMessageResponse
    , PostMessageVariables
    , encodePostMessageVariables
    , postMessage
    , postMessageVariablesDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


postMessage : PostMessageVariables -> GraphQL.Operation.Operation GraphQL.Operation.Mutation GraphQL.Errors.Errors PostMessageMutation
postMessage variables =
    GraphQL.Operation.withQuery
        """mutation PostMessage($message: String!) {
postMessage(message: $message)
}"""
        (Maybe.Just <| encodePostMessageVariables variables)
        postMessageMutationDecoder
        GraphQL.Errors.decoder


type alias PostMessageResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors PostMessageMutation


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
    { postMessage : Maybe.Maybe String
    }


postMessageMutationDecoder : Json.Decode.Decoder PostMessageMutation
postMessageMutationDecoder =
    Json.Decode.map PostMessageMutation
        (Json.Decode.field "postMessage" (Json.Decode.nullable Json.Decode.string))
