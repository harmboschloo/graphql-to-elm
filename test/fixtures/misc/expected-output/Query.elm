module Query
    exposing
        ( Data
        , User2
        , User3
        , User4
        , User
        , User5
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
    { i : User2
    , version : Int
    , me : User3
    , you : Maybe.Maybe User4
    , them : List User3
    , maybeThem : Maybe.Maybe (List (Maybe.Maybe User5))
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map6 Data
        (Json.Decode.field "i" user2Decoder)
        (Json.Decode.field "version" Json.Decode.int)
        (Json.Decode.field "me" user3Decoder)
        (Json.Decode.field "you" (Json.Decode.nullable user4Decoder))
        (Json.Decode.field "them" (Json.Decode.list user3Decoder))
        (Json.Decode.field "maybeThem" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable user5Decoder))))


type alias User2 =
    { name : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map User2
        (Json.Decode.field "name" Json.Decode.string)


type alias User3 =
    { name : String
    , age : Maybe.Maybe Int
    }


user3Decoder : Json.Decode.Decoder User3
user3Decoder =
    Json.Decode.map2 User3
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User4 =
    { name : String
    , friends : Maybe.Maybe (List User)
    , relatives : List User2
    }


user4Decoder : Json.Decode.Decoder User4
user4Decoder =
    Json.Decode.map3 User4
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list userDecoder)))
        (Json.Decode.field "relatives" (Json.Decode.list user2Decoder))


type alias User =
    { id : String
    , age : Maybe.Maybe Int
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User5 =
    { age : Maybe.Maybe Int
    }


user5Decoder : Json.Decode.Decoder User5
user5Decoder =
    Json.Decode.map User5
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
