module SameTypeSameFields
    exposing
        ( Data
        , Person
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
  i {
    name
    age
  }
  me {
    age
    name
  }
}"""


type alias Data =
    { i : Person
    , me : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" personDecoder)


type alias Person =
    { name : String
    , age : Maybe.Maybe Int
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
