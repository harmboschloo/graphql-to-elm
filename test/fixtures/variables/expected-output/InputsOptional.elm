module InputsOptional
    exposing
        ( InputsOptionalVariables
        , OptionalInputs
        , OtherInputs
        , Query
        , inputsOptional
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsOptional : InputsOptionalVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
inputsOptional variables =
    GraphqlToElm.Operation.query
        """query InputsOptional($inputs: OptionalInputs) {
inputsOptional(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsOptionalVariables variables)
        queryDecoder
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


type alias Query =
    { inputsOptional : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
