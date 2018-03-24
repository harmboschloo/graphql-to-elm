module InputsMultiple
    exposing
        ( InputsMultipleVariables
        , Inputs
        , OtherInputs
        , Query
        , inputsMultiple
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsMultiple : InputsMultipleVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
inputsMultiple variables =
    GraphqlToElm.Operation.query
        """query InputsMultiple($inputs: Inputs!, $inputs2: Inputs) {
inputsMultiple(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMultipleVariables variables)
        queryDecoder
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


type alias Query =
    { inputsMultiple : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "inputsMultiple" (Json.Decode.nullable Json.Decode.string))
