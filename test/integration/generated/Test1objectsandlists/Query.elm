module Generated.Test1ObjectsAndLists.Query exposing (Data, Person, Person2, Person3, Person4, Person5, Person6, decoder, query)

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
    parents {
      name
      email
      friends {
        name
        age
      }
    }
  }
  you {
    name
    siblings {
      age
    }
    family {
      name
      friends {
        name
        age
      }
    }
  }
}"""


type alias Person3 =
    { age : Maybe Int
    }


person3Decoder : Json.Decode.Decoder Person3
person3Decoder =
    Json.Decode.map Person3
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias Person =
    { age : Maybe Int
    , name : String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person2 =
    { friends : Maybe (List (Maybe Person))
    , name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable personDecoder))))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person4 =
    { email : Maybe String
    , friends : Maybe (List (Maybe Person))
    , name : String
    }


person4Decoder : Json.Decode.Decoder Person4
person4Decoder =
    Json.Decode.map3 Person4
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable personDecoder))))
        (Json.Decode.field "name" Json.Decode.string)


type alias Person5 =
    { family : Maybe (List Person2)
    , name : String
    , siblings : List (Maybe Person3)
    }


person5Decoder : Json.Decode.Decoder Person5
person5Decoder =
    Json.Decode.map3 Person5
        (Json.Decode.field "family" (Json.Decode.nullable (Json.Decode.list person2Decoder)))
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "siblings" (Json.Decode.list (Json.Decode.nullable person3Decoder)))


type alias Person6 =
    { age : Maybe Int
    , name : String
    , parents : List Person4
    }


person6Decoder : Json.Decode.Decoder Person6
person6Decoder =
    Json.Decode.map3 Person6
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "parents" (Json.Decode.list person4Decoder))


type alias Data =
    { i : Person
    , me : Person6
    , you : Maybe Person5
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map3 Data
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" person6Decoder)
        (Json.Decode.field "you" (Json.Decode.nullable person5Decoder))
