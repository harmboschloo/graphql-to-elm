module Inputs
    exposing
        ( Variables
        , Inputs
        , OtherInputs
        , Data
        , query
        , encodeVariables
        , decoder
        )

import Json.Decode
import Json.Encode


query : String
query =
    """query Inputs($inputs: Inputs!) {
  inputs(inputs: $inputs)
}"""


type alias Variables =
    { inputs : Inputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables { inputs } =
    Json.Encode.object
        [ ( "inputs", encodeInputs inputs )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs { int, float, other } =
    Json.Encode.object
        [ ( "int", Json.Encode.int int )
        , ( "float", Json.Encode.float float )
        , ( "other", encodeOtherInputs other )
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
    { inputs : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputs" (Json.Decode.nullable Json.Decode.string))
