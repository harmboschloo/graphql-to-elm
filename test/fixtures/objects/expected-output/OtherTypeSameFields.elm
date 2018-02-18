module OtherTypeSameFields exposing (Data, Person, Person2, decoder, query)

import Json.Decode


query : String
query =
    """{
  me {
    name
    email
  }
  you {
    name
    email
  }
}"""


type alias Data =
    { me : Person
    , you : Person2
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "me" personDecoder)
        (Json.Decode.field "you" person2Decoder)


type alias Person =
    { email : Maybe String
    , name : String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person2 =
    { email : Maybe String
    , name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "name" Json.Decode.string)
