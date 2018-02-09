module Generated.Test7ObjectsSameTypeSameFields.SameTypeSameFields exposing (Data, Person, decoder, query)

import Json.Decode


query : String
query =
    """{
  i {
    name
    age
  }
  me {
    name
    age
  }
}"""


type alias Person =
    { age : Maybe Int
    , name : String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "name" Json.Decode.string)


type alias Data =
    { i : Person
    , me : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" personDecoder)
