module CustomNullableScalarTypes exposing (Data, decoder, query)

import Data.Date
import Data.Id
import Json.Decode


query : String
query =
    """{
  idOrNull
  dateOrNull
}"""


type alias Data =
    { dateOrNull : Maybe Data.Date.Date
    , idOrNull : Maybe Data.Id.Id
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "dateOrNull" (Json.Decode.nullable Data.Date.decoder))
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Data.Id.decoder))
