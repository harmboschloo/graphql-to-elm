module InputsMixed
    exposing
        ( InputsMixedVariables
        , MixedInputs
        , OtherInputs
        , Query
        , inputsMixed
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


inputsMixed : InputsMixedVariables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
inputsMixed variables =
    GraphqlToElm.Graphql.Operation.query
        """query InputsMixed($inputs: MixedInputs!, $inputs2: MixedInputs) {
inputsMixed(inputs: $inputs, inputs2: $inputs2)
}"""
        (Maybe.Just <| encodeInputsMixedVariables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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


type alias Query =
    { inputsMixed : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "inputsMixed" (Json.Decode.nullable Json.Decode.string))
