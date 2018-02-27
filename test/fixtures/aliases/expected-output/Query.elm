module Query
    exposing
        ( Data
        , User2
        , User
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
    { user1 : User2
    , user2 : User
    , user3 : User2
    , user4 : Maybe.Maybe User
    , user : User2
    , userOrNull : Maybe.Maybe User
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map6 Data
        (Json.Decode.field "user1" user2Decoder)
        (Json.Decode.field "user2" userDecoder)
        (Json.Decode.field "user3" user2Decoder)
        (Json.Decode.field "user4" (Json.Decode.nullable userDecoder))
        (Json.Decode.field "user" user2Decoder)
        (Json.Decode.field "userOrNull" (Json.Decode.nullable userDecoder))


type alias User2 =
    { id : String
    , email : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map2 User2
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias User =
    { id : String
    , name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
