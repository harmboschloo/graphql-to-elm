module CustomScalarTypes
    exposing
        ( Data
        , post
        , query
        , decoder
        )

import Data.Date
import Data.Id
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
  id
  date
}"""


type alias Data =
    { id : Data.Id.Id
    , date : Data.Date.Date
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "id" Data.Id.decoder)
        (Json.Decode.field "date" Data.Date.decoder)
