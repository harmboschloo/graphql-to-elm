module Scalars
    exposing
        ( ScalarsVariables
        , Query
        , scalars
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode
import Json.Encode


scalars : ScalarsVariables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
scalars variables =
    GraphqlToElm.Graphql.Operation.query
        """query Scalars($string: String!, $int: Int!) {
scalars(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsVariables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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


type alias Query =
    { scalars : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "scalars" (Json.Decode.nullable Json.Decode.string))
