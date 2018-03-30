module Inputs
    exposing
        ( InputsResponse
        , InputsVariables
        , Inputs
        , OtherInputs
        , InputsQuery
        , inputs
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


inputs : InputsVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InputsQuery
inputs variables =
    GraphqlToElm.Operation.withQuery
        """query Inputs($inputs: Inputs!) {
inputs(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsVariables variables)
        inputsQueryDecoder
        GraphqlToElm.Errors.decoder


type alias InputsResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors InputsQuery


type alias InputsVariables =
    { inputs : Inputs
    }


encodeInputsVariables : InputsVariables -> Json.Encode.Value
encodeInputsVariables inputs =
    Json.Encode.object
        [ ( "inputs", encodeInputs inputs.inputs )
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


type alias InputsQuery =
    { inputs : Maybe.Maybe String
    }


inputsQueryDecoder : Json.Decode.Decoder InputsQuery
inputsQueryDecoder =
    Json.Decode.map InputsQuery
        (Json.Decode.field "inputs" (Json.Decode.nullable Json.Decode.string))
