module Skip
    exposing
        ( SkipVariables
        , Query
        , skip
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


skip : SkipVariables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
skip variables =
    GraphqlToElm.Graphql.Operation.query
        """query Skip($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeSkipVariables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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
