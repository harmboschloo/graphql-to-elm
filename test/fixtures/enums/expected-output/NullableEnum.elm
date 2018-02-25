module NullableEnum
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
  binaryOrNull
}"""


type alias Data =
    { binaryOrNull : Maybe.Maybe Data.Binary.Binary
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "binaryOrNull" (Json.Decode.nullable Data.Binary.decoder))
