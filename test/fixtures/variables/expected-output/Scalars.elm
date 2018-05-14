module Scalars
    exposing
        ( ScalarsResponse
        , ScalarsVariables
        , ScalarsQuery
        , scalars
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


scalars : ScalarsVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors ScalarsQuery
scalars variables =
    GraphQL.Operation.withQuery
        """query Scalars($string: String!, $int: Int!) {
scalars(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsVariables variables)
        scalarsQueryDecoder
        GraphQL.Errors.decoder


type alias ScalarsResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors ScalarsQuery


type alias ScalarsVariables =
    { string : String
    , int : Int
    }


encodeScalarsVariables : ScalarsVariables -> Json.Encode.Value
encodeScalarsVariables inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        , ( "int", Json.Encode.int inputs.int )
        ]


type alias ScalarsQuery =
    { scalars : Maybe.Maybe String
    }


scalarsQueryDecoder : Json.Decode.Decoder ScalarsQuery
scalarsQueryDecoder =
    Json.Decode.map ScalarsQuery
        (Json.Decode.field "scalars" (Json.Decode.nullable Json.Decode.string))
