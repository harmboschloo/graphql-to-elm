module Mixed1
    exposing
        ( Mixed1Variables
        , Query
        , mixed1
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


mixed1 : Mixed1Variables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
mixed1 variables =
    GraphqlToElm.Graphql.Operation.query
        """query Mixed1($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed1Variables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Mixed1Variables =
    { withSchool : Bool
    , withCity : Bool
    }


encodeMixed1Variables : Mixed1Variables -> Json.Encode.Value
encodeMixed1Variables inputs =
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
