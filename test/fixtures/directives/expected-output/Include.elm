module Include
    exposing
        ( IncludeVariables
        , IncludeQuery
        , include
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


include : IncludeVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors IncludeQuery
include variables =
    GraphqlToElm.Operation.withQuery
        """query Include($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeIncludeVariables variables)
        includeQueryDecoder
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


type alias IncludeQuery =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


includeQueryDecoder : Json.Decode.Decoder IncludeQuery
includeQueryDecoder =
    Json.Decode.map3 IncludeQuery
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.nonNullField "school" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.field "city" Json.Decode.string)
