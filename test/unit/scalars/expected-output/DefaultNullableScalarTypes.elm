module DefaultNullableScalarTypes exposing (Data, decoder, query)

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
    { booleanOrNull : Maybe Bool
    , floatOrNull : Maybe Float
    , idOrNull : Maybe String
    , intOrNull : Maybe Int
    , stringOrNull : Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "booleanOrNull" (Json.Decode.nullable Json.Decode.bool))
        (Json.Decode.field "floatOrNull" (Json.Decode.nullable Json.Decode.float))
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "intOrNull" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "stringOrNull" (Json.Decode.nullable Json.Decode.string))
