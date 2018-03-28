module Skip
    exposing
        ( SkipVariables
        , SkipQuery
        , skip
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


skip : SkipVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors SkipQuery
skip variables =
    GraphqlToElm.Operation.withQuery
        """query Skip($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeSkipVariables variables)
        skipQueryDecoder
        GraphqlToElm.Errors.decoder


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


type alias SkipQuery =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


skipQueryDecoder : Json.Decode.Decoder SkipQuery
skipQueryDecoder =
    Json.Decode.map3 SkipQuery
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.nonNullField "school" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.field "city" Json.Decode.string)
