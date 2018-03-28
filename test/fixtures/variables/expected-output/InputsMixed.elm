module InputsMixed
    exposing
        ( InputsMixedVariables
        , MixedInputs
        , OtherInputs
        , InputsMixedQuery
        , inputsMixed
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsMixed : InputsMixedVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InputsMixedQuery
inputsMixed variables =
    GraphqlToElm.Operation.withQuery
        """query InputsMixed($inputs: MixedInputs!, $inputs2: MixedInputs) {
inputsMixed(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMixedVariables variables)
        inputsMixedQueryDecoder
        GraphqlToElm.Errors.decoder


type alias InputsMixedVariables =
    { inputs : MixedInputs
    , inputs2 : GraphqlToElm.Optional.Optional MixedInputs
    }


encodeInputsMixedVariables : InputsMixedVariables -> Json.Encode.Value
encodeInputsMixedVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "inputs", (encodeMixedInputs >> GraphqlToElm.Optional.Present) inputs.inputs )
        , ( "inputs2", (GraphqlToElm.Optional.map encodeMixedInputs) inputs.inputs2 )
        ]


type alias MixedInputs =
    { int : Int
    , float : GraphqlToElm.Optional.Optional Float
    , other : OtherInputs
    }


encodeMixedInputs : MixedInputs -> Json.Encode.Value
encodeMixedInputs inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "int", (Json.Encode.int >> GraphqlToElm.Optional.Present) inputs.int )
        , ( "float", (GraphqlToElm.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (encodeOtherInputs >> GraphqlToElm.Optional.Present) inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


type alias InputsMixedQuery =
    { inputsMixed : Maybe.Maybe String
    }


inputsMixedQueryDecoder : Json.Decode.Decoder InputsMixedQuery
inputsMixedQueryDecoder =
    Json.Decode.map InputsMixedQuery
        (Json.Decode.field "inputsMixed" (Json.Decode.nullable Json.Decode.string))
