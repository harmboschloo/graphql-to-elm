module Enum exposing (Data, decoder, query)

import Data.Binary
import Json.Decode


query : String
query =
    """{
  binary
}"""


type alias Data =
    { binary : Data.Binary.Binary
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "binary" Data.Binary.decoder)
