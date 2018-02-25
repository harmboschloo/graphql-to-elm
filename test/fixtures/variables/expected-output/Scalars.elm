module Scalars
    exposing
        ( Variables
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
    """query Scalars($string: String!, $int: Int!) {
  scalars(string: $string, int: $int)
}"""


type alias Variables =
    { string : String
    , int : Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        , ( "int", Json.Encode.int inputs.int )
        ]


type alias Data =
    { scalars : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalars" (Json.Decode.nullable Json.Decode.string))
