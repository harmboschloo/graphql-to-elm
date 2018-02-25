module CustomNullableScalarTypes
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
  idOrNull
  dateOrNull
}"""


type alias Data =
    { idOrNull : Maybe.Maybe Data.Id.Id
    , dateOrNull : Maybe.Maybe Data.Date.Date
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Data.Id.decoder))
        (Json.Decode.field "dateOrNull" (Json.Decode.nullable Data.Date.decoder))
