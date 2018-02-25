module ScalarsOptional
    exposing
        ( Variables
        , Data
        , post
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.Http
import GraphqlToElm.Optional
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
    """query ScalarsOptional($string: String, $int: Int) {
  scalarsOptional(string: $string, int: $int)
}"""


type alias Variables =
    { string : GraphqlToElm.Optional.Optional String
    , int : GraphqlToElm.Optional.Optional Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "string", (GraphqlToElm.Optional.map Json.Encode.string) inputs.string )
        , ( "int", (GraphqlToElm.Optional.map Json.Encode.int) inputs.int )
        ]


type alias Data =
    { scalarsOptional : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalarsOptional" (Json.Decode.nullable Json.Decode.string))
