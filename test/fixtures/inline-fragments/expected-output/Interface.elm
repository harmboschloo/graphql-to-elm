module Interface
    exposing
        ( Data
        , Animal
        , query
        , decoder
        )

import Json.Decode


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
    { animal : Animal
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "animal" animalDecoder)


type alias Animal =
    { color : String
    , hairy : Bool
    , fins : Int
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map3 Animal
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "hairy" Json.Decode.bool)
        (Json.Decode.field "fins" Json.Decode.int)
