module InterfaceMultiple
    exposing
        ( Data
        , Animal(..)
        , Mammal
        , Bird
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
    """query InterfaceMultiple {
  animal {
    ... on Mammal {
      subclass
    }
    ... on Bird {
      color
      canFly
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
    = OnBird Bird
    | OnMammal Mammal


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnBird birdDecoder
        , Json.Decode.map OnMammal mammalDecoder
        ]


type alias Mammal =
    { subclass : String
    }


mammalDecoder : Json.Decode.Decoder Mammal
mammalDecoder =
    Json.Decode.map Mammal
        (Json.Decode.field "subclass" Json.Decode.string)


type alias Bird =
    { color : String
    , canFly : Bool
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "canFly" Json.Decode.bool)
