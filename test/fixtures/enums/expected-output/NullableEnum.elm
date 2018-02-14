module NullableEnum exposing (Data, decoder, query)

import Data.Binary
import Json.Decode


query : String
query =
    """{
  binaryOrNull
}"""


type alias Data =
    { binaryOrNull : Maybe Data.Binary.Binary
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "binaryOrNull" (Json.Decode.nullable Data.Binary.decoder))
