module Queries.Mutations exposing
    ( PostMessageMutation
    , PostMessageResponse
    , PostMessageVariables
    , postMessage
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


type alias PostMessageMutation =
    { postMessage : Maybe.Maybe String
    }


postMessageMutationDecoder : Json.Decode.Decoder PostMessageMutation
postMessageMutationDecoder =
    Json.Decode.map PostMessageMutation
        (Json.Decode.field "postMessage" (Json.Decode.nullable Json.Decode.string))
