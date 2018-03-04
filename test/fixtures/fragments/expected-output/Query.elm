module Query
    exposing
        ( Variables
        , Data
        , User
        , Flip(..)
        , Heads
        , Tails
        , post
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.Http
import Json.Decode
import Json.Encode


post : String -> Variables -> GraphqlToElm.Http.Request Data
post url variables =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = encodeVariables variables
        }
        decoder


query : String
query =
    """query Fragments($id: String!) {
  user1: user {
    ...fields
  }
  user2: user {
    ...fields
  }
  user3: userOrNull {
    ...fields
  }
  user4: userById(id: $id) {
    ...fields
  }
  flip {
    ...heads
    ... on Tails {
      length
    }
  }
}

fragment fields on User {
  id
  name
  email
}

fragment heads on Heads {
  name
}"""


type alias Variables =
    { id : String
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    Json.Encode.object
        [ ( "id", Json.Encode.string inputs.id )
        ]


type alias Data =
    { user1 : User
    , user2 : User
    , user3 : Maybe.Maybe User
    , user4 : Maybe.Maybe User
    , flip : Flip
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "user1" userDecoder)
        (Json.Decode.field "user2" userDecoder)
        (Json.Decode.field "user3" (Json.Decode.nullable userDecoder))
        (Json.Decode.field "user4" (Json.Decode.nullable userDecoder))
        (Json.Decode.field "flip" flipDecoder)


type alias User =
    { id : String
    , name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type Flip
    = OnHeads Heads
    | OnTails Tails


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , Json.Decode.map OnTails tailsDecoder
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
