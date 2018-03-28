module ScalarsMixed
    exposing
        ( ScalarsMixedVariables
        , ScalarsMixedQuery
        , scalarsMixed
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


scalarsMixed : ScalarsMixedVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors ScalarsMixedQuery
scalarsMixed variables =
    GraphqlToElm.Operation.withQuery
        """query ScalarsMixed($string: String, $int: Int!) {
scalarsMixed(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsMixedVariables variables)
        scalarsMixedQueryDecoder
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


type alias ScalarsMixedQuery =
    { scalarsMixed : Maybe.Maybe String
    }


scalarsMixedQueryDecoder : Json.Decode.Decoder ScalarsMixedQuery
scalarsMixedQueryDecoder =
    Json.Decode.map ScalarsMixedQuery
        (Json.Decode.field "scalarsMixed" (Json.Decode.nullable Json.Decode.string))
