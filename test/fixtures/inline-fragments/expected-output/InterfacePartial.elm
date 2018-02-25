module InterfacePartial
    exposing
        ( Data
        , AnimalUnion(..)
        , Dog
        , Animal
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
    """query InterfacePartial {
  animal {
    color
    ... on Dog {
      hairy
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
    | OnAnimal Animal


animalUnionDecoder : Json.Decode.Decoder AnimalUnion
animalUnionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnAnimal animalDecoder
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


type alias Animal =
    { color : String
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map Animal
        (Json.Decode.field "color" Json.Decode.string)
