module ScalarsMixed
    exposing
        ( Variables
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
    """query ScalarsMixed($string: String, $int: Int!) {
  scalarsMixed(string: $string, int: $int)
}"""


type alias Variables =
    { string : GraphqlToElm.Optional.Optional String
    , int : Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "string", (GraphqlToElm.Optional.map Json.Encode.string) inputs.string )
        , ( "int", (Json.Encode.int >> GraphqlToElm.Optional.Present) inputs.int )
        ]


type alias Data =
    { scalarsMixed : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalarsMixed" (Json.Decode.nullable Json.Decode.string))
