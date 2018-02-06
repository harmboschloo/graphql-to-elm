module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
import Generated.Test0misc.Query


type alias Test =
    { id : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ { id = "test0-misc"
      , query = Generated.Test0misc.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map (always "ok") Generated.Test0misc.Query.decoder
      }
    ]  
