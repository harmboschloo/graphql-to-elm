module Union
    exposing
        ( Data
        , Flip
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """query Union {
  flip {
    ... on Heads {
      name
    }
    ... on Tails {
      length
    }
  }
}"""


type alias Data =
    { flip : Flip
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "flip" flipDecoder)


type alias Flip =
    { name : String
    , length : Float
    }


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.map2 Flip
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "length" Json.Decode.float)
