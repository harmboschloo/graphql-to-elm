module CustomScalarTypes
    exposing
        ( Data
        , query
        , decoder
        )

import Data.Date
import Data.Id
import Json.Decode


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
