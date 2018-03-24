module Include
    exposing
        ( IncludeVariables
        , Query
        , include
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


include : IncludeVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
include variables =
    GraphqlToElm.Operation.query
        """query Include($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeIncludeVariables variables)
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias IncludeVariables =
    { withSchool : Bool
    , withCity : Bool
    }


encodeIncludeVariables : IncludeVariables -> Json.Encode.Value
encodeIncludeVariables inputs =
    Json.Encode.object
        [ ( "withSchool", Json.Encode.bool inputs.withSchool )
        , ( "withCity", Json.Encode.bool inputs.withCity )
        ]


type alias Query =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map3 Query
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.nonNullField "school" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.field "city" Json.Decode.string)
