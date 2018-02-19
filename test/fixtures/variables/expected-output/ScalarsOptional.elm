module ScalarsOptional
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
    """query ScalarsOptional($string: String, $int: Int) {
  scalarsOptional(string: $string, int: $int)
}"""


type alias Variables =
    { string : GraphqlToElm.OptionalInput.OptionalInput String
    , int : GraphqlToElm.OptionalInput.OptionalInput Int
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.OptionalInput.encodeObject
        [ ( "string", (GraphqlToElm.OptionalInput.map Json.Encode.string) inputs.string )
        , ( "int", (GraphqlToElm.OptionalInput.map Json.Encode.int) inputs.int )
        ]


type alias Data =
    { scalarsOptional : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "scalarsOptional" (Json.Decode.nullable Json.Decode.string))
