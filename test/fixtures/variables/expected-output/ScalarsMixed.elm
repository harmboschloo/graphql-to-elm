module ScalarsMixed
    exposing
        ( ScalarsMixedVariables
        , Query
        , scalarsMixed
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


scalarsMixed : ScalarsMixedVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
scalarsMixed variables =
    GraphqlToElm.Operation.query
        """query ScalarsMixed($string: String, $int: Int!) {
scalarsMixed(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsMixedVariables variables)
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias ScalarsMixedVariables =
    { string : GraphqlToElm.Optional.Optional String
    , int : Int
    }


encodeScalarsMixedVariables : ScalarsMixedVariables -> Json.Encode.Value
encodeScalarsMixedVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "string", (GraphqlToElm.Optional.map Json.Encode.string) inputs.string )
        , ( "int", (Json.Encode.int >> GraphqlToElm.Optional.Present) inputs.int )
        ]


type alias Query =
    { scalarsMixed : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "scalarsMixed" (Json.Decode.nullable Json.Decode.string))
