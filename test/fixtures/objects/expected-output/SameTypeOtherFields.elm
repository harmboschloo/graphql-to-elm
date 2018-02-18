module SameTypeOtherFields
    exposing
        ( Data
        , Person2
        , Person
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """{
  i {
    name
    age
  }
  me {
    email
    age
  }
}"""


type alias Data =
    { i : Person2
    , me : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "i" person2Decoder)
        (Json.Decode.field "me" personDecoder)


type alias Person2 =
    { name : String
    , age : Maybe.Maybe Int
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias Person =
    { email : Maybe.Maybe String
    , age : Maybe.Maybe Int
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
