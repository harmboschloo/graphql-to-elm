module CustomScalarTypes exposing (Data, decoder, query)

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
    { date : Data.Date.Date
    , id : Data.Id.Id
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "date" Data.Date.decoder)
        (Json.Decode.field "id" Data.Id.decoder)
