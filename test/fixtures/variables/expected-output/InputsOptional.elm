module InputsOptional
    exposing
        ( Variables
        , OptionalInputs
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
    """query InputsOptional($inputs: OptionalInputs) {
  inputsOptional(inputs: $inputs)
}"""


type alias Variables =
    { inputs : GraphqlToElm.OptionalInput.OptionalInput OptionalInputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables { inputs } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "inputs", (GraphqlToElm.OptionalInput.map encodeOptionalInputs) inputs )
        ]


type alias OptionalInputs =
    { int : GraphqlToElm.OptionalInput.OptionalInput Int
    , float : GraphqlToElm.OptionalInput.OptionalInput Float
    , other : GraphqlToElm.OptionalInput.OptionalInput OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs { int, float, other } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "int", (GraphqlToElm.OptionalInput.map Json.Encode.int) int )
        , ( "float", (GraphqlToElm.OptionalInput.map Json.Encode.float) float )
        , ( "other", (GraphqlToElm.OptionalInput.map encodeOtherInputs) other )
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
    { inputsOptional : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
