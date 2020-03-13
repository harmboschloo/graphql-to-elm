module InputsMixed exposing
    ( InputsMixedQuery
    , InputsMixedResponse
    , InputsMixedVariables
    , MixedInputs
    , OtherInputs
    , encodeInputsMixedVariables
    , encodeMixedInputs
    , encodeOtherInputs
    , inputsMixed
    , inputsMixedVariablesDecoder
    , mixedInputsDecoder
    , otherInputsDecoder
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


inputsMixed : InputsMixedVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InputsMixedQuery
inputsMixed variables =
    GraphQL.Operation.withQuery
        """query InputsMixed($inputs: MixedInputs!, $inputs2: MixedInputs) {
inputsMixed(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMixedVariables variables)
        inputsMixedQueryDecoder
        GraphQL.Errors.decoder


type alias InputsMixedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InputsMixedQuery


type alias InputsMixedVariables =
    { inputs : MixedInputs
    , inputs2 : GraphQL.Optional.Optional MixedInputs
    }


encodeInputsMixedVariables : InputsMixedVariables -> Json.Encode.Value
encodeInputsMixedVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "inputs", (encodeMixedInputs >> GraphQL.Optional.Present) inputs.inputs )
        , ( "inputs2", GraphQL.Optional.map encodeMixedInputs inputs.inputs2 )
        ]


type alias MixedInputs =
    { int : Int
    , float : GraphQL.Optional.Optional Float
    , other : OtherInputs
    }


encodeMixedInputs : MixedInputs -> Json.Encode.Value
encodeMixedInputs inputs =
    GraphQL.Optional.encodeObject
        [ ( "int", (Json.Encode.int >> GraphQL.Optional.Present) inputs.int )
        , ( "float", GraphQL.Optional.map Json.Encode.float inputs.float )
        , ( "other", (encodeOtherInputs >> GraphQL.Optional.Present) inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


inputsMixedVariablesDecoder : Json.Decode.Decoder InputsMixedVariables
inputsMixedVariablesDecoder =
    Json.Decode.map2 InputsMixedVariables
        (Json.Decode.field "inputs" mixedInputsDecoder)
        (GraphQL.Optional.fieldDecoder "inputs2" mixedInputsDecoder)


mixedInputsDecoder : Json.Decode.Decoder MixedInputs
mixedInputsDecoder =
    Json.Decode.map3 MixedInputs
        (Json.Decode.field "int" Json.Decode.int)
        (GraphQL.Optional.fieldDecoder "float" Json.Decode.float)
        (Json.Decode.field "other" otherInputsDecoder)


otherInputsDecoder : Json.Decode.Decoder OtherInputs
otherInputsDecoder =
    Json.Decode.map OtherInputs
        (Json.Decode.field "string" Json.Decode.string)


type alias InputsMixedQuery =
    { inputsMixed : Maybe.Maybe String
    }


inputsMixedQueryDecoder : Json.Decode.Decoder InputsMixedQuery
inputsMixedQueryDecoder =
    Json.Decode.map InputsMixedQuery
        (Json.Decode.field "inputsMixed" (Json.Decode.nullable Json.Decode.string))
