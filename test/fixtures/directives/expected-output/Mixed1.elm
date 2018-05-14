module Mixed1
    exposing
        ( Mixed1Response
        , Mixed1Variables
        , Mixed1Query
        , mixed1
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


mixed1 : Mixed1Variables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Mixed1Query
mixed1 variables =
    GraphQL.Operation.withQuery
        """query Mixed1($withSchool: Boolean!, $withCity: Boolean!) {
name
school @include(if: $withSchool)
city @skip(if: $withCity)
}"""
        (Maybe.Just <| encodeMixed1Variables variables)
        mixed1QueryDecoder
        GraphQL.Errors.decoder


type alias Mixed1Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Mixed1Query


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
    , city : GraphQL.Optional.Optional String
    }


mixed1QueryDecoder : Json.Decode.Decoder Mixed1Query
mixed1QueryDecoder =
    Json.Decode.map3 Mixed1Query
        (Json.Decode.field "name" Json.Decode.string)
        (GraphQL.Optional.nonNullFieldDecoder "school" Json.Decode.string)
        (GraphQL.Optional.fieldDecoder "city" Json.Decode.string)
