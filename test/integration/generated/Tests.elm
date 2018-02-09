module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
import Generated.Test0Misc.Query
import Generated.Test1ObjectsAndLists.Query


type alias Test =
    { id : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ { id = "test0-misc"
      , query = Generated.Test0Misc.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test0Misc.Query.decoder
      }
    , { id = "test1-objects_and_lists"
      , query = Generated.Test1ObjectsAndLists.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test1ObjectsAndLists.Query.decoder
      }
    ]  
