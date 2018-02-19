module Lists
    exposing
        ( Variables
        , Inputs
        , OptionalInputs
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
    """query Lists(
  $ints: [Int!]
  $floats: [Float]
  $inputs: [Inputs!]!
  $inputs2: [OptionalInputs]!
) {
  lists(ints: $ints, floats: $floats, inputs: $inputs, inputs2: $inputs2)
}"""


type alias Variables =
    { ints : GraphqlToElm.OptionalInput.OptionalInput (List Int)
    , floats : GraphqlToElm.OptionalInput.OptionalInput (List (GraphqlToElm.OptionalInput.OptionalInput Float))
    , inputs : List Inputs
    , inputs2 : List (GraphqlToElm.OptionalInput.OptionalInput OptionalInputs)
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "ints", (GraphqlToElm.OptionalInput.map (List.map Json.Encode.int >> Json.Encode.list)) inputs.ints )
        , ( "floats", (GraphqlToElm.OptionalInput.map (GraphqlToElm.OptionalInput.encodeList Json.Encode.float)) inputs.floats )
        , ( "inputs", ((List.map encodeInputs >> Json.Encode.list) >> GraphqlToElm.OptionalInput.Present) inputs.inputs )
        , ( "inputs2", ((GraphqlToElm.OptionalInput.encodeList encodeOptionalInputs) >> GraphqlToElm.OptionalInput.Present) inputs.inputs2 )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs2
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs inputs =
    Json.Encode.object
        [ ( "int", Json.Encode.int inputs.int )
        , ( "float", Json.Encode.float inputs.float )
        , ( "other", encodeOtherInputs2 inputs.other )
        ]


type alias OtherInputs2 =
    { string : String
    }


encodeOtherInputs2 : OtherInputs2 -> Json.Encode.Value
encodeOtherInputs2 inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
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
    { lists : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "lists" (Json.Decode.nullable Json.Decode.string))
