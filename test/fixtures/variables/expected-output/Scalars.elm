module Scalars
    exposing
        ( ScalarsResponse
        , ScalarsVariables
        , ScalarsQuery
        , scalars
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


scalars : ScalarsVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors ScalarsQuery
scalars variables =
    GraphqlToElm.Operation.withQuery
        """query Scalars($string: String!, $int: Int!) {
scalars(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsVariables variables)
        scalarsQueryDecoder
        GraphqlToElm.Errors.decoder


type alias ScalarsResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors ScalarsQuery


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
