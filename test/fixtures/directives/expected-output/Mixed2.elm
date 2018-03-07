module Mixed2
    exposing
        ( Mixed2Variables
        , Query
        , mixed2
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


mixed2 : Mixed2Variables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
mixed2 variables =
    GraphqlToElm.Graphql.Operation.query
        """query Mixed2($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed2Variables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Mixed2Variables =
    { withSchool : Bool
    , withCity : Bool
    }


encodeMixed2Variables : Mixed2Variables -> Json.Encode.Value
encodeMixed2Variables inputs =
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
