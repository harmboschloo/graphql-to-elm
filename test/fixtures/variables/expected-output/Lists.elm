module Lists
    exposing
        ( ListsResponse
        , ListsVariables
        , Inputs
        , OtherInputs
        , OptionalInputs
        , ListsQuery
        , lists
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


lists : ListsVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors ListsQuery
lists variables =
    GraphQL.Operation.withQuery
        """query Lists(
$ints: [Int!]
$floats: [Float]
$inputs: [Inputs!]!
$inputs2: [OptionalInputs]!
) {
lists(ints: $ints, floats: $floats, inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeListsVariables variables)
        listsQueryDecoder
        GraphQL.Errors.decoder


type alias ListsResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors ListsQuery


type alias ListsVariables =
    { ints : GraphQL.Optional.Optional (List Int)
    , floats : GraphQL.Optional.Optional (List (GraphQL.Optional.Optional Float))
    , inputs : List Inputs
    , inputs2 : List (GraphQL.Optional.Optional OptionalInputs)
    }


encodeListsVariables : ListsVariables -> Json.Encode.Value
encodeListsVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "ints", (GraphQL.Optional.map (List.map Json.Encode.int >> Json.Encode.list)) inputs.ints )
        , ( "floats", (GraphQL.Optional.map (GraphQL.Optional.encodeList Json.Encode.float)) inputs.floats )
        , ( "inputs", ((List.map encodeInputs >> Json.Encode.list) >> GraphQL.Optional.Present) inputs.inputs )
        , ( "inputs2", ((GraphQL.Optional.encodeList encodeOptionalInputs) >> GraphQL.Optional.Present) inputs.inputs2 )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs inputs =
    Json.Encode.object
        [ ( "int", Json.Encode.int inputs.int )
        , ( "float", Json.Encode.float inputs.float )
        , ( "other", encodeOtherInputs inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


type alias OptionalInputs =
    { int : GraphQL.Optional.Optional Int
    , float : GraphQL.Optional.Optional Float
    , other : GraphQL.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphQL.Optional.encodeObject
        [ ( "int", (GraphQL.Optional.map Json.Encode.int) inputs.int )
        , ( "float", (GraphQL.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (GraphQL.Optional.map encodeOtherInputs) inputs.other )
        ]


type alias ListsQuery =
    { lists : Maybe.Maybe String
    }


listsQueryDecoder : Json.Decode.Decoder ListsQuery
listsQueryDecoder =
    Json.Decode.map ListsQuery
        (Json.Decode.field "lists" (Json.Decode.nullable Json.Decode.string))
