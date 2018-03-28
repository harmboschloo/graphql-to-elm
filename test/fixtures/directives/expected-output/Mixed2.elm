module Mixed2
    exposing
        ( Mixed2Variables
        , Mixed2Query
        , mixed2
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Decode
import Json.Decode
import Json.Encode


mixed2 : Mixed2Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Mixed2Query
mixed2 variables =
    GraphqlToElm.Operation.withQuery
        """query Mixed2($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed2Variables variables)
        mixed2QueryDecoder
        GraphqlToElm.Errors.decoder


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


type alias Mixed2Query =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


mixed2QueryDecoder : Json.Decode.Decoder Mixed2Query
mixed2QueryDecoder =
    Json.Decode.map3 Mixed2Query
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.nonNullField "school" Json.Decode.string)
        (GraphqlToElm.Optional.Decode.field "city" Json.Decode.string)
