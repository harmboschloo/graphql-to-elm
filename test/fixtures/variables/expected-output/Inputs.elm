module Inputs
    exposing
        ( Variables
        , Inputs
        , OtherInputs
        , Data
        , post
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.Http
import Json.Decode
import Json.Encode


post : String -> Variables -> GraphqlToElm.Http.Request Data
post url variables =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = encodeVariables variables
        }
        decoder


query : String
query =
    """query Inputs($inputs: Inputs!) {
  inputs(inputs: $inputs)
}"""


type alias Variables =
    { inputs : Inputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    Json.Encode.object
        [ ( "inputs", encodeInputs inputs.inputs )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs inputs =
    Json.Encode.object
        [ ( "int", Json.Encode.int inputs.int )
        , ( "float", Json.Encode.float inputs.float )
        , ( "other", encodeOtherInputs inputs.other )
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
    { inputs : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputs" (Json.Decode.nullable Json.Decode.string))
