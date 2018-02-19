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
encodeVariables { ints, floats, inputs, inputs2 } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "ints", (GraphqlToElm.OptionalInput.map (List.map Json.Encode.int >> Json.Encode.list)) ints )
        , ( "floats", (GraphqlToElm.OptionalInput.map (GraphqlToElm.OptionalInput.encodeList Json.Encode.float)) floats )
        , ( "inputs", ((List.map encodeInputs >> Json.Encode.list) >> GraphqlToElm.OptionalInput.Present) inputs )
        , ( "inputs2", ((GraphqlToElm.OptionalInput.encodeList encodeOptionalInputs) >> GraphqlToElm.OptionalInput.Present) inputs2 )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs2
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs { int, float, other } =
    Json.Encode.object
        [ ( "int", Json.Encode.int int )
        , ( "float", Json.Encode.float float )
        , ( "other", encodeOtherInputs2 other )
        ]


type alias OtherInputs2 =
    { string : String
    }


encodeOtherInputs2 : OtherInputs2 -> Json.Encode.Value
encodeOtherInputs2 { string } =
    Json.Encode.object
        [ ( "string", Json.Encode.string string )
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
    { lists : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "lists" (Json.Decode.nullable Json.Decode.string))
