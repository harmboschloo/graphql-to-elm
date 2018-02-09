module Generated.Test6ObjectsNested.Nested exposing (Data, Person, Person2, decoder, query)

import Json.Decode


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


type alias Person2 =
    { age : Maybe Int
    , email : Maybe String
    , name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map3 Person2
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person =
    { age : Maybe Int
    , bestFriend : Maybe Person2
    , name : String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map3 Person
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "bestFriend" (Json.Decode.nullable person2Decoder))
        (Json.Decode.field "name" Json.Decode.string)


type alias Data =
    { i : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "i" personDecoder)
