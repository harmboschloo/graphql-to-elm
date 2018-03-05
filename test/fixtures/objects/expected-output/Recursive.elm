module Recursive
    exposing
        ( Data
        , Comment4
        , Comment3
        , Comment2
        , Comment
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
  comments {
    message
    responses {
      message
      responses {
        message
        responses {
          message
        }
      }
    }
  }
}"""


type alias Data =
    { comments : List Comment4
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "comments" (Json.Decode.list comment4Decoder))


type alias Comment4 =
    { message : String
    , responses : List Comment3
    }


comment4Decoder : Json.Decode.Decoder Comment4
comment4Decoder =
    Json.Decode.map2 Comment4
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list comment3Decoder))


type alias Comment3 =
    { message : String
    , responses : List Comment2
    }


comment3Decoder : Json.Decode.Decoder Comment3
comment3Decoder =
    Json.Decode.map2 Comment3
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list comment2Decoder))


type alias Comment2 =
    { message : String
    , responses : List Comment
    }


comment2Decoder : Json.Decode.Decoder Comment2
comment2Decoder =
    Json.Decode.map2 Comment2
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "responses" (Json.Decode.list commentDecoder))


type alias Comment =
    { message : String
    }


commentDecoder : Json.Decode.Decoder Comment
commentDecoder =
    Json.Decode.map Comment
        (Json.Decode.field "message" Json.Decode.string)
