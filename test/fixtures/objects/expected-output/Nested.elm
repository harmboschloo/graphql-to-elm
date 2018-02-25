module Nested
    exposing
        ( Data
        , Person
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
  i {
    name
    age
    bestFriend {
      name
      age
      email
    }
  }
}"""


type alias Data =
    { i : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "i" personDecoder)


type alias Person =
    { name : String
    , age : Maybe.Maybe Int
    , bestFriend : Maybe.Maybe Person2
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map3 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "bestFriend" (Json.Decode.nullable person2Decoder))


type alias Person2 =
    { name : String
    , age : Maybe.Maybe Int
    , email : Maybe.Maybe String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map3 Person2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
