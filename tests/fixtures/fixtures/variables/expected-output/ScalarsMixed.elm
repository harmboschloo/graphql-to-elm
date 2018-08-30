module ScalarsMixed exposing
    ( ScalarsMixedQuery
    , ScalarsMixedResponse
    , ScalarsMixedVariables
    , scalarsMixed
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


scalarsMixed : ScalarsMixedVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors ScalarsMixedQuery
scalarsMixed variables =
    GraphQL.Operation.withQuery
        """query ScalarsMixed($string: String, $int: Int!) {
scalarsMixed(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsMixedVariables variables)
        scalarsMixedQueryDecoder
        GraphQL.Errors.decoder


type alias ScalarsMixedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors ScalarsMixedQuery


type alias ScalarsMixedVariables =
    { string : GraphQL.Optional.Optional String
    , int : Int
    }


encodeScalarsMixedVariables : ScalarsMixedVariables -> Json.Encode.Value
encodeScalarsMixedVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "string", GraphQL.Optional.map Json.Encode.string inputs.string )
        , ( "int", (Json.Encode.int >> GraphQL.Optional.Present) inputs.int )
        ]


type alias ScalarsMixedQuery =
    { scalarsMixed : Maybe.Maybe String
    }


scalarsMixedQueryDecoder : Json.Decode.Decoder ScalarsMixedQuery
scalarsMixedQueryDecoder =
    Json.Decode.map ScalarsMixedQuery
        (Json.Decode.field "scalarsMixed" (Json.Decode.nullable Json.Decode.string))
