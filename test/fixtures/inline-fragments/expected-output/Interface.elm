module Interface
    exposing
        ( Data
        , AnimalUnion(..)
        , Dog
        , Dolphin
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
    """query Interface {
  animal {
    color
    ... on Dog {
      hairy
    }
    ... on Dolphin {
      fins
    }
  }
}"""


type alias Data =
    { animal : AnimalUnion
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "animal" animalUnionDecoder)


type AnimalUnion
    = OnDog Dog
    | OnDolphin Dolphin


animalUnionDecoder : Json.Decode.Decoder AnimalUnion
animalUnionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnDolphin dolphinDecoder
        ]


type alias Dog =
    { hairy : Bool
    , color : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "hairy" Json.Decode.bool)
        (Json.Decode.field "color" Json.Decode.string)


type alias Dolphin =
    { fins : Int
    , color : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "fins" Json.Decode.int)
        (Json.Decode.field "color" Json.Decode.string)
