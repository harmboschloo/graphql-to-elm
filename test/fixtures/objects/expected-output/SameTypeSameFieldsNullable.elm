module SameTypeSameFieldsNullable
    exposing
        ( Data
        , Person2
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
  you {
    email
    age
  }
  youOrNull {
    age
    email
  }
}"""


type alias Data =
    { you : Person2
    , youOrNull : Maybe.Maybe Person2
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "you" person2Decoder)
        (Json.Decode.field "youOrNull" (Json.Decode.nullable person2Decoder))


type alias Person2 =
    { email : Maybe.Maybe String
    , age : Maybe.Maybe Int
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
