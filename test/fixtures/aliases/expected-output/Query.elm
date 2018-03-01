module Query
    exposing
        ( Data
        , User
        , User2
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
    """query Aliases {
  user1: user {
    id
    email
  }
  user2: user {
    id
    name
  }
  user3: user {
    id
    email
  }
  user4: userOrNull {
    id
    name
  }
  user {
    id
    email
  }
  userOrNull {
    id
    name
  }
}"""


type alias Data =
    { user1 : User
    , user2 : User2
    , user3 : User
    , user4 : Maybe.Maybe User2
    , user : User
    , userOrNull : Maybe.Maybe User2
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map6 Data
        (Json.Decode.field "user1" userDecoder)
        (Json.Decode.field "user2" user2Decoder)
        (Json.Decode.field "user3" userDecoder)
        (Json.Decode.field "user4" (Json.Decode.nullable user2Decoder))
        (Json.Decode.field "user" userDecoder)
        (Json.Decode.field "userOrNull" (Json.Decode.nullable user2Decoder))


type alias User =
    { id : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias User2 =
    { id : String
    , name : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map2 User2
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
