module InterfacePlain
    exposing
        ( Data
        , Animal
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """query InterfacePlain {
  animal {
    color
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
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map Animal
        (Json.Decode.field "color" Json.Decode.string)
