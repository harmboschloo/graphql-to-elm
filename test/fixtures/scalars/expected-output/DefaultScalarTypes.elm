module DefaultScalarTypes exposing (Data, decoder, query)

import Json.Decode


query : String
query =
    """{
  int
  float
  string
  boolean
  id
}"""


type alias Data =
    { boolean : Bool
    , float : Float
    , id : String
    , int : Int
    , string : String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "boolean" Json.Decode.bool)
        (Json.Decode.field "float" Json.Decode.float)
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "int" Json.Decode.int)
        (Json.Decode.field "string" Json.Decode.string)
