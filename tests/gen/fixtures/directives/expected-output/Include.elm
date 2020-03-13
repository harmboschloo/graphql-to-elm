module Include exposing
    ( IncludeQuery
    , IncludeResponse
    , IncludeVariables
    , encodeIncludeVariables
    , include
    , includeVariablesDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


include : IncludeVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors IncludeQuery
include variables =
    GraphQL.Operation.withQuery
        """query Include($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeIncludeVariables variables)
        includeQueryDecoder
        GraphQL.Errors.decoder


type alias IncludeResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors IncludeQuery


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


includeVariablesDecoder : Json.Decode.Decoder IncludeVariables
includeVariablesDecoder =
    Json.Decode.map2 IncludeVariables
        (Json.Decode.field "withSchool" Json.Decode.bool)
        (Json.Decode.field "withCity" Json.Decode.bool)


type alias IncludeQuery =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphQL.Optional.Optional String
    }


includeQueryDecoder : Json.Decode.Decoder IncludeQuery
includeQueryDecoder =
    Json.Decode.map3 IncludeQuery
        (Json.Decode.field "name" Json.Decode.string)
        (GraphQL.Optional.nonNullFieldDecoder "school" Json.Decode.string)
        (GraphQL.Optional.fieldDecoder "city" Json.Decode.string)
