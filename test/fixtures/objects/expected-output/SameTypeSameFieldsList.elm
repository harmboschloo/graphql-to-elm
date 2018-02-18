module SameTypeSameFieldsList
    exposing
        ( Data
        , Person
        , Person2
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """{
  me {
    bestFriend {
      name
    }
    friends {
      name
    }
  }
}"""


type alias Data =
    { me : Person
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "me" personDecoder)


type alias Person =
    { bestFriend : Maybe.Maybe Person2
    , friends : Maybe.Maybe (List (Maybe.Maybe Person2))
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "bestFriend" (Json.Decode.nullable person2Decoder))
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable person2Decoder))))


type alias Person2 =
    { name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map Person2
        (Json.Decode.field "name" Json.Decode.string)
