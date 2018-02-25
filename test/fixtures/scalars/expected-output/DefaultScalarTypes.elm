module DefaultScalarTypes
    exposing
        ( Data
        , post
        , query
        , decoder
        )

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
  int
  float
  string
  boolean
  id
}"""


type alias Data =
    { int : Int
    , float : Float
    , string : String
    , boolean : Bool
    , id : String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "int" Json.Decode.int)
        (Json.Decode.field "float" Json.Decode.float)
        (Json.Decode.field "string" Json.Decode.string)
        (Json.Decode.field "boolean" Json.Decode.bool)
        (Json.Decode.field "id" Json.Decode.string)
