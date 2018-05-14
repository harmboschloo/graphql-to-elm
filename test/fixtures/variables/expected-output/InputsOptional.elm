module InputsOptional
    exposing
        ( InputsOptionalResponse
        , InputsOptionalVariables
        , OptionalInputs
        , OtherInputs
        , InputsOptionalQuery
        , inputsOptional
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Optional.Encode
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
    GraphQL.Optional.Encode.object
        [ ( "inputs", (GraphQL.Optional.map encodeOptionalInputs) inputs.inputs )
        ]


type alias OptionalInputs =
    { int : GraphQL.Optional.Optional Int
    , float : GraphQL.Optional.Optional Float
    , other : GraphQL.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphQL.Optional.Encode.object
        [ ( "int", (GraphQL.Optional.map Json.Encode.int) inputs.int )
        , ( "float", (GraphQL.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (GraphQL.Optional.map encodeOtherInputs) inputs.other )
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
