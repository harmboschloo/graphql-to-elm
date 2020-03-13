module CustomScalarInput exposing
    ( AtQuery
    , AtResponse
    , AtVariables
    , at
    , atVariablesDecoder
    , encodeAtVariables
    )

import Data.Time
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


at : AtVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors AtQuery
at variables =
    GraphQL.Operation.withQuery
        """query At($time: Time!) {
at(time: $time)
}"""
        (Maybe.Just <| encodeAtVariables variables)
        atQueryDecoder
        GraphQL.Errors.decoder


type alias AtResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors AtQuery


type alias AtVariables =
    { time : Data.Time.Posix
    }


encodeAtVariables : AtVariables -> Json.Encode.Value
encodeAtVariables inputs =
    Json.Encode.object
        [ ( "time", Data.Time.encode inputs.time )
        ]


atVariablesDecoder : Json.Decode.Decoder AtVariables
atVariablesDecoder =
    Json.Decode.map AtVariables
        (Json.Decode.field "time" Data.Time.decoder)


type alias AtQuery =
    { at : Maybe.Maybe Int
    }


atQueryDecoder : Json.Decode.Decoder AtQuery
atQueryDecoder =
    Json.Decode.map AtQuery
        (Json.Decode.field "at" (Json.Decode.nullable Json.Decode.int))
