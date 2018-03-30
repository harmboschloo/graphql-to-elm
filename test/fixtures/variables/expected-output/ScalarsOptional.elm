module ScalarsOptional
    exposing
        ( ScalarsOptionalResponse
        , ScalarsOptionalVariables
        , ScalarsOptionalQuery
        , scalarsOptional
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


scalarsOptional : ScalarsOptionalVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors ScalarsOptionalQuery
scalarsOptional variables =
    GraphqlToElm.Operation.withQuery
        """query ScalarsOptional($string: String, $int: Int) {
scalarsOptional(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsOptionalVariables variables)
        scalarsOptionalQueryDecoder
        GraphqlToElm.Errors.decoder


type alias ScalarsOptionalResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors ScalarsOptionalQuery


type alias ScalarsOptionalVariables =
    { string : GraphqlToElm.Optional.Optional String
    , int : GraphqlToElm.Optional.Optional Int
    }


encodeScalarsOptionalVariables : ScalarsOptionalVariables -> Json.Encode.Value
encodeScalarsOptionalVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "string", (GraphqlToElm.Optional.map Json.Encode.string) inputs.string )
        , ( "int", (GraphqlToElm.Optional.map Json.Encode.int) inputs.int )
        ]


type alias ScalarsOptionalQuery =
    { scalarsOptional : Maybe.Maybe String
    }


scalarsOptionalQueryDecoder : Json.Decode.Decoder ScalarsOptionalQuery
scalarsOptionalQueryDecoder =
    Json.Decode.map ScalarsOptionalQuery
        (Json.Decode.field "scalarsOptional" (Json.Decode.nullable Json.Decode.string))
