module Skip exposing
    ( SkipQuery
    , SkipResponse
    , SkipVariables
    , encodeSkipVariables
    , skip
    , skipVariablesDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


skip : SkipVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors SkipQuery
skip variables =
    GraphQL.Operation.withQuery
        """query Skip($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeSkipVariables variables)
        skipQueryDecoder
        GraphQL.Errors.decoder


type alias SkipResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors SkipQuery


type alias SkipVariables =
    { withSchool : Bool
    , withCity : Bool
    }


encodeSkipVariables : SkipVariables -> Json.Encode.Value
encodeSkipVariables inputs =
    Json.Encode.object
        [ ( "withSchool", Json.Encode.bool inputs.withSchool )
        , ( "withCity", Json.Encode.bool inputs.withCity )
        ]


skipVariablesDecoder : Json.Decode.Decoder SkipVariables
skipVariablesDecoder =
    Json.Decode.map2 SkipVariables
        (Json.Decode.field "withSchool" Json.Decode.bool)
        (Json.Decode.field "withCity" Json.Decode.bool)


type alias SkipQuery =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphQL.Optional.Optional String
    }


skipQueryDecoder : Json.Decode.Decoder SkipQuery
skipQueryDecoder =
    Json.Decode.map3 SkipQuery
        (Json.Decode.field "name" Json.Decode.string)
        (GraphQL.Optional.nonNullFieldDecoder "school" Json.Decode.string)
        (GraphQL.Optional.fieldDecoder "city" Json.Decode.string)
