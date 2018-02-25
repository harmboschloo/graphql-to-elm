module Enum
    exposing
        ( Data
        , post
        , query
        , decoder
        )

import Data.Binary
import GraphqlToElm.Http
import Json.Decode
import Json.Encode


post : String -> GraphqlToElm.Http.Request Data
post url =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = Json.Encode.null
        }
        decoder


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
