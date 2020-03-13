module InputsOptional exposing
    ( InputsOptionalQuery
    , InputsOptionalResponse
    , InputsOptionalVariables
    , OptionalInputs
    , OtherInputs
    , encodeInputsOptionalVariables
    , encodeOptionalInputs
    , encodeOtherInputs
    , inputsOptional
    , inputsOptionalVariablesDecoder
    , optionalInputsDecoder
    , otherInputsDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


inputsOptional : InputsOptionalVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InputsOptionalQuery
inputsOptional variables =
    GraphQL.Operation.withQuery
        """query InputsOptional($inputs: OptionalInputs) {
inputsOptional(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsOptionalVariables variables)
        inputsOptionalQueryDecoder
        GraphQL.Errors.decoder


type alias InputsOptionalResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InputsOptionalQuery


type alias InputsOptionalVariables =
    { inputs : GraphQL.Optional.Optional OptionalInputs
    }


encodeInputsOptionalVariables : InputsOptionalVariables -> Json.Encode.Value
encodeInputsOptionalVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "inputs", GraphQL.Optional.map encodeOptionalInputs inputs.inputs )
        ]


type alias OptionalInputs =
    { int : GraphQL.Optional.Optional Int
    , float : GraphQL.Optional.Optional Float
    , other : GraphQL.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphQL.Optional.encodeObject
        [ ( "int", GraphQL.Optional.map Json.Encode.int inputs.int )
        , ( "float", GraphQL.Optional.map Json.Encode.float inputs.float )
        , ( "other", GraphQL.Optional.map encodeOtherInputs inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


inputsOptionalVariablesDecoder : Json.Decode.Decoder InputsOptionalVariables
inputsOptionalVariablesDecoder =
    Json.Decode.map InputsOptionalVariables
        (GraphQL.Optional.fieldDecoder "inputs" optionalInputsDecoder)


optionalInputsDecoder : Json.Decode.Decoder OptionalInputs
optionalInputsDecoder =
    Json.Decode.map3 OptionalInputs
        (GraphQL.Optional.fieldDecoder "int" Json.Decode.int)
        (GraphQL.Optional.fieldDecoder "float" Json.Decode.float)
        (GraphQL.Optional.fieldDecoder "other" otherInputsDecoder)


otherInputsDecoder : Json.Decode.Decoder OtherInputs
otherInputsDecoder =
    Json.Decode.map OtherInputs
        (Json.Decode.field "string" Json.Decode.string)


type alias InputsOptionalQuery =
    { inputsOptional : Maybe.Maybe String
    }


inputsOptionalQueryDecoder : Json.Decode.Decoder InputsOptionalQuery
inputsOptionalQueryDecoder =
    Json.Decode.map InputsOptionalQuery
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
