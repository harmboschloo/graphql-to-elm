module InputsMultiple exposing
    ( Inputs
    , InputsMultipleQuery
    , InputsMultipleResponse
    , InputsMultipleVariables
    , OtherInputs
    , encodeInputs
    , encodeInputsMultipleVariables
    , encodeOtherInputs
    , inputsDecoder
    , inputsMultiple
    , inputsMultipleVariablesDecoder
    , otherInputsDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


inputsMultiple : InputsMultipleVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InputsMultipleQuery
inputsMultiple variables =
    GraphQL.Operation.withQuery
        """query InputsMultiple($inputs: Inputs!, $inputs2: Inputs) {
inputsMultiple(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMultipleVariables variables)
        inputsMultipleQueryDecoder
        GraphQL.Errors.decoder


type alias InputsMultipleResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InputsMultipleQuery


type alias InputsMultipleVariables =
    { inputs : Inputs
    , inputs2 : GraphQL.Optional.Optional Inputs
    }


encodeInputsMultipleVariables : InputsMultipleVariables -> Json.Encode.Value
encodeInputsMultipleVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "inputs", (encodeInputs >> GraphQL.Optional.Present) inputs.inputs )
        , ( "inputs2", GraphQL.Optional.map encodeInputs inputs.inputs2 )
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


inputsMultipleVariablesDecoder : Json.Decode.Decoder InputsMultipleVariables
inputsMultipleVariablesDecoder =
    Json.Decode.map2 InputsMultipleVariables
        (Json.Decode.field "inputs" inputsDecoder)
        (GraphQL.Optional.fieldDecoder "inputs2" inputsDecoder)


inputsDecoder : Json.Decode.Decoder Inputs
inputsDecoder =
    Json.Decode.map3 Inputs
        (Json.Decode.field "int" Json.Decode.int)
        (Json.Decode.field "float" Json.Decode.float)
        (Json.Decode.field "other" otherInputsDecoder)


otherInputsDecoder : Json.Decode.Decoder OtherInputs
otherInputsDecoder =
    Json.Decode.map OtherInputs
        (Json.Decode.field "string" Json.Decode.string)


type alias InputsMultipleQuery =
    { inputsMultiple : Maybe.Maybe String
    }


inputsMultipleQueryDecoder : Json.Decode.Decoder InputsMultipleQuery
inputsMultipleQueryDecoder =
    Json.Decode.map InputsMultipleQuery
        (Json.Decode.field "inputsMultiple" (Json.Decode.nullable Json.Decode.string))
