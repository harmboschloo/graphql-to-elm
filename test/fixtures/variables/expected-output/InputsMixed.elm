module InputsMixed
    exposing
        ( Variables
        , MixedInputs
        , OtherInputs
        , Data
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.Optional
import Json.Decode
import Json.Encode


query : String
query =
    """query InputsMixed($inputs: MixedInputs!, $inputs2: MixedInputs) {
  inputsMixed(inputs: $inputs, inputs2: $inputs2)
}"""


type alias Variables =
    { inputs : MixedInputs
    , inputs2 : GraphqlToElm.Optional.Optional MixedInputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.Optional.encodeObject
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
    GraphqlToElm.Optional.encodeObject
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


type alias Data =
    { inputsMixed : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputsMixed" (Json.Decode.nullable Json.Decode.string))
