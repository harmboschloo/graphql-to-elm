module Mixed1
    exposing
        ( Mixed1Variables
        , Mixed1Query
        , mixed1
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


mixed1 : Mixed1Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Mixed1Query
mixed1 variables =
    GraphqlToElm.Operation.withQuery
        """query Mixed1($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed1Variables variables)
        mixed1QueryDecoder
        GraphqlToElm.Errors.decoder


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


type alias Mixed1Query =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


mixed1QueryDecoder : Json.Decode.Decoder Mixed1Query
mixed1QueryDecoder =
    Json.Decode.map3 Mixed1Query
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.nonNullField "school" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.field "city" Json.Decode.string)
