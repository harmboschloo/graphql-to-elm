module Inputs exposing
    ( Inputs
    , InputsQuery
    , InputsResponse
    , InputsVariables
    , OtherInputs
    , inputs
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


inputs : InputsVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InputsQuery
inputs variables =
    GraphQL.Operation.withQuery
        """query Inputs($inputs: Inputs!) {
inputs(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsVariables variables)
        inputsQueryDecoder
        GraphQL.Errors.decoder


type alias InputsResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InputsQuery


type alias InputsVariables =
    { inputs : Inputs
    }


encodeInputsVariables : InputsVariables -> Json.Encode.Value
encodeInputsVariables inputs2 =
    Json.Encode.object
        [ ( "inputs", encodeInputs inputs2.inputs )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs inputs2 =
    Json.Encode.object
        [ ( "int", Json.Encode.int inputs2.int )
        , ( "float", Json.Encode.float inputs2.float )
        , ( "other", encodeOtherInputs inputs2.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs2 =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs2.string )
        ]


type alias InputsQuery =
    { inputs : Maybe.Maybe String
    }


inputsQueryDecoder : Json.Decode.Decoder InputsQuery
inputsQueryDecoder =
    Json.Decode.map InputsQuery
        (Json.Decode.field "inputs" (Json.Decode.nullable Json.Decode.string))
