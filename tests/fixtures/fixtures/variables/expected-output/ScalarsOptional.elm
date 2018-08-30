module ScalarsOptional exposing
    ( ScalarsOptionalQuery
    , ScalarsOptionalResponse
    , ScalarsOptionalVariables
    , scalarsOptional
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


scalarsOptional : ScalarsOptionalVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors ScalarsOptionalQuery
scalarsOptional variables =
    GraphQL.Operation.withQuery
        """query ScalarsOptional($string: String, $int: Int) {
scalarsOptional(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsOptionalVariables variables)
        scalarsOptionalQueryDecoder
        GraphQL.Errors.decoder


type alias ScalarsOptionalResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors ScalarsOptionalQuery


type alias ScalarsOptionalVariables =
    { string : GraphQL.Optional.Optional String
    , int : GraphQL.Optional.Optional Int
    }


encodeScalarsOptionalVariables : ScalarsOptionalVariables -> Json.Encode.Value
encodeScalarsOptionalVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "string", GraphQL.Optional.map Json.Encode.string inputs.string )
        , ( "int", GraphQL.Optional.map Json.Encode.int inputs.int )
        ]


type alias ScalarsOptionalQuery =
    { scalarsOptional : Maybe.Maybe String
    }


scalarsOptionalQueryDecoder : Json.Decode.Decoder ScalarsOptionalQuery
scalarsOptionalQueryDecoder =
    Json.Decode.map ScalarsOptionalQuery
        (Json.Decode.field "scalarsOptional" (Json.Decode.nullable Json.Decode.string))
