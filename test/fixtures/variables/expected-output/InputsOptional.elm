module InputsOptional
    exposing
        ( InputsOptionalVariables
        , OptionalInputs
        , OtherInputs
        , InputsOptionalQuery
        , inputsOptional
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsOptional : InputsOptionalVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InputsOptionalQuery
inputsOptional variables =
    GraphqlToElm.Operation.withQuery
        """query InputsOptional($inputs: OptionalInputs) {
inputsOptional(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsOptionalVariables variables)
        inputsOptionalQueryDecoder
        GraphqlToElm.Errors.decoder


type alias InputsOptionalVariables =
    { inputs : GraphqlToElm.Optional.Optional OptionalInputs
    }


encodeInputsOptionalVariables : InputsOptionalVariables -> Json.Encode.Value
encodeInputsOptionalVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "inputs", (GraphqlToElm.Optional.map encodeOptionalInputs) inputs.inputs )
        ]


type alias OptionalInputs =
    { int : GraphqlToElm.Optional.Optional Int
    , float : GraphqlToElm.Optional.Optional Float
    , other : GraphqlToElm.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "int", (GraphqlToElm.Optional.map Json.Encode.int) inputs.int )
        , ( "float", (GraphqlToElm.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (GraphqlToElm.Optional.map encodeOtherInputs) inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


type alias InputsOptionalQuery =
    { inputsOptional : Maybe.Maybe String
    }


inputsOptionalQueryDecoder : Json.Decode.Decoder InputsOptionalQuery
inputsOptionalQueryDecoder =
    Json.Decode.map InputsOptionalQuery
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
