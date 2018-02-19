module InputsMixed
    exposing
        ( Variables
        , MixedInputs2
        , MixedInputs
        , OtherInputs2
        , OtherInputs
        , Data
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.OptionalInput
import Json.Decode
import Json.Encode


query : String
query =
    """query InputsMixed($inputs: MixedInputs!, $inputs2: MixedInputs) {
  inputsMixed(inputs: $inputs, inputs2: $inputs2)
}"""


type alias Variables =
    { inputs : MixedInputs2
    , inputs2 : GraphqlToElm.OptionalInput.OptionalInput MixedInputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables { inputs, inputs2 } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "inputs", (encodeMixedInputs2 >> GraphqlToElm.OptionalInput.Present) inputs )
        , ( "inputs2", (GraphqlToElm.OptionalInput.map encodeMixedInputs) inputs2 )
        ]


type alias MixedInputs2 =
    { int : Int
    , float : GraphqlToElm.OptionalInput.OptionalInput Float
    , other : OtherInputs2
    }


encodeMixedInputs2 : MixedInputs2 -> Json.Encode.Value
encodeMixedInputs2 { int, float, other } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "int", (Json.Encode.int >> GraphqlToElm.OptionalInput.Present) int )
        , ( "float", (GraphqlToElm.OptionalInput.map Json.Encode.float) float )
        , ( "other", (encodeOtherInputs2 >> GraphqlToElm.OptionalInput.Present) other )
        ]


type alias OtherInputs2 =
    { string : String
    }


encodeOtherInputs2 : OtherInputs2 -> Json.Encode.Value
encodeOtherInputs2 { string } =
    Json.Encode.object
        [ ( "string", Json.Encode.string string )
        ]


type alias MixedInputs =
    { int : Int
    , float : GraphqlToElm.OptionalInput.OptionalInput Float
    , other : OtherInputs
    }


encodeMixedInputs : MixedInputs -> Json.Encode.Value
encodeMixedInputs { int, float, other } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "int", (Json.Encode.int >> GraphqlToElm.OptionalInput.Present) int )
        , ( "float", (GraphqlToElm.OptionalInput.map Json.Encode.float) float )
        , ( "other", (encodeOtherInputs >> GraphqlToElm.OptionalInput.Present) other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs { string } =
    Json.Encode.object
        [ ( "string", Json.Encode.string string )
        ]


type alias Data =
    { inputsMixed : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputsMixed" (Json.Decode.nullable Json.Decode.string))
