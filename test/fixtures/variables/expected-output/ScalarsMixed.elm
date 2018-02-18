module ScalarsMixed
    exposing
        ( Variables
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
    """query ScalarsMixed($string: String, $int: Int!) {
  scalarsMixed(string: $string, int: $int)
}"""


type alias Variables =
    { string : GraphqlToElm.OptionalInput.OptionalInput String
    , int : Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables { string, int } =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "string", (GraphqlToElm.OptionalInput.map Json.Encode.string) string )
        , ( "int", (Json.Encode.int >> GraphqlToElm.OptionalInput.Present) int )
        ]


type alias Data =
    { scalarsMixed : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalarsMixed" (Json.Decode.nullable Json.Decode.string))
