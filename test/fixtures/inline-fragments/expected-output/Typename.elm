module Typename
    exposing
        ( Data
        , Animal(..)
        , Dog
        , Dolphin
        , Bird
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
    """query Typename {
  animal {
    ... on Dog {
      __typename
      color
    }
    ... on Dolphin {
      __typename
      color
    }
    ... on Bird {
      color
    }
  }
}"""


type alias Data =
    { animal : Animal
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "animal" animalDecoder)


type Animal
    = OnDog Dog
    | OnDolphin Dolphin
    | OnBird Bird


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnDolphin dolphinDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type alias Dog =
    { typename : String
    , color : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "__typename" (GraphqlToElm.DecodeHelpers.constantDecoder "Dog" Json.Decode.string))
        (Json.Decode.field "color" Json.Decode.string)


type alias Dolphin =
    { typename : String
    , color : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "__typename" (GraphqlToElm.DecodeHelpers.constantDecoder "Dolphin" Json.Decode.string))
        (Json.Decode.field "color" Json.Decode.string)


type alias Bird =
    { color : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map Bird
        (Json.Decode.field "color" Json.Decode.string)
