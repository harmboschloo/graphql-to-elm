module OtherTypeSameFields
    exposing
        ( Data
        , Person
        , Person2
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
    { name : String
    , email : Maybe.Maybe String
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map2 Person
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))


type alias Person2 =
    { name : String
    , email : Maybe.Maybe String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map2 Person2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
