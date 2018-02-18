module Query
    exposing
        ( Data
        , User
        , User4
        , User5
        , User3
        , User2
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """query TestQuery {
  i {
    name
  }
  version
  me {
    name
    age
  }
  you {
    name
    friends {
      id
      age
    }
    relatives {
      name
    }
  }
  them {
    age
    name
  }
  maybeThem {
    age
  }
}"""


type alias Data =
    { i : User
    , version : Int
    , me : User4
    , you : Maybe.Maybe User5
    , them : List User4
    , maybeThem : Maybe.Maybe (List (Maybe.Maybe User3))
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map6 Data
        (Json.Decode.field "i" userDecoder)
        (Json.Decode.field "version" Json.Decode.int)
        (Json.Decode.field "me" user4Decoder)
        (Json.Decode.field "you" (Json.Decode.nullable user5Decoder))
        (Json.Decode.field "them" (Json.Decode.list user4Decoder))
        (Json.Decode.field "maybeThem" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable user3Decoder))))


type alias User =
    { name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map User
        (Json.Decode.field "name" Json.Decode.string)


type alias User4 =
    { name : String
    , age : Maybe.Maybe Int
    }


user4Decoder : Json.Decode.Decoder User4
user4Decoder =
    Json.Decode.map2 User4
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User5 =
    { name : String
    , friends : Maybe.Maybe (List User2)
    , relatives : List User
    }


user5Decoder : Json.Decode.Decoder User5
user5Decoder =
    Json.Decode.map3 User5
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list user2Decoder)))
        (Json.Decode.field "relatives" (Json.Decode.list userDecoder))


type alias User2 =
    { id : String
    , age : Maybe.Maybe Int
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map2 User2
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User3 =
    { age : Maybe.Maybe Int
    }


user3Decoder : Json.Decode.Decoder User3
user3Decoder =
    Json.Decode.map User3
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
