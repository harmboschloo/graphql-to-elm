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

import GraphqlToElm.Optional
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
    { ints : GraphqlToElm.Optional.Optional (List Int)
    , floats : GraphqlToElm.Optional.Optional (List (GraphqlToElm.Optional.Optional Float))
    , inputs : List Inputs
    , inputs2 : List (GraphqlToElm.Optional.Optional OptionalInputs)
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "ints", (GraphqlToElm.Optional.map (List.map Json.Encode.int >> Json.Encode.list)) inputs.ints )
        , ( "floats", (GraphqlToElm.Optional.map (GraphqlToElm.Optional.encodeList Json.Encode.float)) inputs.floats )
        , ( "inputs", ((List.map encodeInputs >> Json.Encode.list) >> GraphqlToElm.Optional.Present) inputs.inputs )
        , ( "inputs2", ((GraphqlToElm.Optional.encodeList encodeOptionalInputs) >> GraphqlToElm.Optional.Present) inputs.inputs2 )
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
    { int : GraphqlToElm.Optional.Optional Int
    , float : GraphqlToElm.Optional.Optional Float
    , other : GraphqlToElm.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "int", (GraphqlToElm.Optional.map Json.Encode.int) inputs.int )
        , ( "float", (GraphqlToElm.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (GraphqlToElm.Optional.map encodeOtherInputs) inputs.other )
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
