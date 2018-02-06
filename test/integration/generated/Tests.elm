module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
import Generated.Misc.Query


type alias Test =
    { id : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ { id = "misc"
      , query = Generated.Misc.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map (always "ok") Generated.Misc.Query.decoder
      }
    ]
