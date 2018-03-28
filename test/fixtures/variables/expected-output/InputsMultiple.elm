module InputsMultiple
    exposing
        ( InputsMultipleVariables
        , Inputs
        , OtherInputs
        , InputsMultipleQuery
        , inputsMultiple
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsMultiple : InputsMultipleVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InputsMultipleQuery
inputsMultiple variables =
    GraphqlToElm.Operation.withQuery
        """query InputsMultiple($inputs: Inputs!, $inputs2: Inputs) {
inputsMultiple(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMultipleVariables variables)
        inputsMultipleQueryDecoder
        GraphqlToElm.Errors.decoder


type alias InputsMultipleVariables =
    { inputs : Inputs
    , inputs2 : GraphqlToElm.Optional.Optional Inputs
    }


encodeInputsMultipleVariables : InputsMultipleVariables -> Json.Encode.Value
encodeInputsMultipleVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "inputs", (encodeInputs >> GraphqlToElm.Optional.Present) inputs.inputs )
        , ( "inputs2", (GraphqlToElm.Optional.map encodeInputs) inputs.inputs2 )
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


type alias InputsMultipleQuery =
    { inputsMultiple : Maybe.Maybe String
    }


inputsMultipleQueryDecoder : Json.Decode.Decoder InputsMultipleQuery
inputsMultipleQueryDecoder =
    Json.Decode.map InputsMultipleQuery
        (Json.Decode.field "inputsMultiple" (Json.Decode.nullable Json.Decode.string))
