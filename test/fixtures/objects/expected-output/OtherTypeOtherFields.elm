module OtherTypeOtherFields
    exposing
        ( Data
        , Person
        , Dog
        , Person2
        , Person22
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
  i {
    dog {
      name
    }
  }
  me {
    name
  }
  you {
    email
  }
}"""


type alias Data =
    { i : Person
    , me : Person2
    , you : Person22
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map3 Data
        (Json.Decode.field "i" personDecoder)
        (Json.Decode.field "me" person2Decoder)
        (Json.Decode.field "you" person22Decoder)


type alias Person =
    { dog : Maybe.Maybe Dog
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map Person
        (Json.Decode.field "dog" (Json.Decode.nullable dogDecoder))


type alias Dog =
    { name : Maybe.Maybe String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))


type alias Person2 =
    { name : String
    }


person2Decoder : Json.Decode.Decoder Person2
person2Decoder =
    Json.Decode.map Person2
        (Json.Decode.field "name" Json.Decode.string)


type alias Person22 =
    { email : Maybe.Maybe String
    }


person22Decoder : Json.Decode.Decoder Person22
person22Decoder =
    Json.Decode.map Person22
        (Json.Decode.field "email" (Json.Decode.nullable Json.Decode.string))
