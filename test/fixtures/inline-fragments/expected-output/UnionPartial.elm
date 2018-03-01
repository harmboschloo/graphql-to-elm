module UnionPartial
    exposing
        ( Data
        , Flip(..)
        , Heads
        , Flip2(..)
        , Tails
        , post
        , query
        , decoder
        )

import GraphqlToElm.DecodeHelpers
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
    """query UnionPartial {
  flip {
    ... on Heads {
      name
    }
  }
  flipOrNull {
    ... on Tails {
      length
    }
  }
}"""


type alias Data =
    { flip : Flip
    , flipOrNull : Maybe.Maybe Flip2
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "flip" flipDecoder)
        (Json.Decode.field "flipOrNull" (Json.Decode.nullable flip2Decoder))


type Flip
    = OnHeads Heads
    | OnOtherFlip


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , GraphqlToElm.DecodeHelpers.emptyObjectDecoder OnOtherFlip
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type Flip2
    = OnTails Tails
    | OnOtherFlip2


flip2Decoder : Json.Decode.Decoder Flip2
flip2Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnTails tailsDecoder
        , GraphqlToElm.DecodeHelpers.emptyObjectDecoder OnOtherFlip2
        ]


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
