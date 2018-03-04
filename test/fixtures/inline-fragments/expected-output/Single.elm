module Single
    exposing
        ( Data
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
    """query Single {
  single: animal {
    ... on Animal {
      color
      size
    }
  }
  shared: animal {
    size
    ... on Animal {
      color
    }
  }
}"""


type alias Data =
    { single : Animal
    , shared : Animal
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "single" animalDecoder)
        (Json.Decode.field "shared" animalDecoder)


type alias Animal =
    { color : String
    , size : Float
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map2 Animal
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "size" Json.Decode.float)
