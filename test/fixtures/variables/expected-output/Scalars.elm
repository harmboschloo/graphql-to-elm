module Scalars
    exposing
        ( Variables
        , Data
        , query
        , encodeVariables
        , decoder
        )

import Json.Decode
import Json.Encode


query : String
query =
    """query Scalars($string: String!, $int: Int!) {
  scalars(string: $string, int: $int)
}"""


type alias Variables =
    { string : String
    , int : Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables { string, int } =
    Json.Encode.object
        [ ( "string", Json.Encode.string string )
        , ( "int", Json.Encode.int int )
        ]


type alias Data =
    { scalars : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalars" (Json.Decode.nullable Json.Decode.string))
