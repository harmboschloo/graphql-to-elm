module ScalarsOptional
    exposing
        ( ScalarsOptionalVariables
        , Query
        , scalarsOptional
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


scalarsOptional : ScalarsOptionalVariables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
scalarsOptional variables =
    GraphqlToElm.Graphql.Operation.query
        """query ScalarsOptional($string: String, $int: Int) {
scalarsOptional(string: $string, int: $int)
}"""
        (Maybe.Just <| encodeScalarsOptionalVariables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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


type alias Query =
    { scalarsOptional : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "scalarsOptional" (Json.Decode.nullable Json.Decode.string))
