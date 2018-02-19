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
encodeVariables inputs =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "inputs", (GraphqlToElm.OptionalInput.map encodeOptionalInputs) inputs.inputs )
        ]


type alias OptionalInputs =
    { int : GraphqlToElm.OptionalInput.OptionalInput Int
    , float : GraphqlToElm.OptionalInput.OptionalInput Float
    , other : GraphqlToElm.OptionalInput.OptionalInput OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "int", (GraphqlToElm.OptionalInput.map Json.Encode.int) inputs.int )
        , ( "float", (GraphqlToElm.OptionalInput.map Json.Encode.float) inputs.float )
        , ( "other", (GraphqlToElm.OptionalInput.map encodeOtherInputs) inputs.other )
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
    { inputsOptional : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
