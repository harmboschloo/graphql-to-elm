module SameTypeOtherFields exposing (Data, Person, Person2, decoder, query)

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
    { age : Maybe Int
    , name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person =
    { age : Maybe Int
    , email : Maybe String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
