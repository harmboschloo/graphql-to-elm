module Mixed2 exposing
    ( Mixed2Query
    , Mixed2Response
    , Mixed2Variables
    , encodeMixed2Variables
    , mixed2
    , mixed2VariablesDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


mixed2 : Mixed2Variables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Mixed2Query
mixed2 variables =
    GraphQL.Operation.withQuery
        """query Mixed2($withSchool: Boolean!, $withCity: Boolean!) {
name
school @skip(if: $withSchool)
city @include(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed2Variables variables)
        mixed2QueryDecoder
        GraphQL.Errors.decoder


type alias Mixed2Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Mixed2Query


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


mixed2VariablesDecoder : Json.Decode.Decoder Mixed2Variables
mixed2VariablesDecoder =
    Json.Decode.map2 Mixed2Variables
        (Json.Decode.field "withSchool" Json.Decode.bool)
        (Json.Decode.field "withCity" Json.Decode.bool)


type alias Mixed2Query =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphQL.Optional.Optional String
    }


mixed2QueryDecoder : Json.Decode.Decoder Mixed2Query
mixed2QueryDecoder =
    Json.Decode.map3 Mixed2Query
        (Json.Decode.field "name" Json.Decode.string)
        (GraphQL.Optional.nonNullFieldDecoder "school" Json.Decode.string)
        (GraphQL.Optional.fieldDecoder "city" Json.Decode.string)
