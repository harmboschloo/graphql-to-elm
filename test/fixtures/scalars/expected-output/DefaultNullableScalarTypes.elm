module DefaultNullableScalarTypes
    exposing
        ( Data
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """{
  intOrNull
  floatOrNull
  stringOrNull
  booleanOrNull
  idOrNull
}"""


type alias Data =
    { intOrNull : Maybe.Maybe Int
    , floatOrNull : Maybe.Maybe Float
    , stringOrNull : Maybe.Maybe String
    , booleanOrNull : Maybe.Maybe Bool
    , idOrNull : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "intOrNull" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "floatOrNull" (Json.Decode.nullable Json.Decode.float))
        (Json.Decode.field "stringOrNull" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "booleanOrNull" (Json.Decode.nullable Json.Decode.bool))
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Json.Decode.string))
