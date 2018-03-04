module TypenameSharedMore
    exposing
        ( Data
        , Animal
        , OnAnimal(..)
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
    """query TypenameSharedMore {
  animal {
    __typename
    size
    ... on Dog {
      color
    }
    ... on Dolphin {
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


type alias Animal =
    { size : Float
    , on : OnAnimal
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map2 Animal
        (Json.Decode.field "size" Json.Decode.float)
        onAnimalDecoder


type OnAnimal
    = OnDog Dog
    | OnDolphin Dolphin
    | OnBird Bird


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnDolphin dolphinDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type alias Dog =
    { color : String
    , typename : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.DecodeHelpers.constantDecoder "Dog" Json.Decode.string))


type alias Dolphin =
    { color : String
    , typename : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.DecodeHelpers.constantDecoder "Dolphin" Json.Decode.string))


type alias Bird =
    { color : String
    , typename : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.DecodeHelpers.constantDecoder "Bird" Json.Decode.string))
