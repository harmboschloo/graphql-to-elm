module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
import Generated.Test0Misc.Query
import Generated.Test1Objects_and_lists.Query
import Generated.Test2DefaultScalarsTypes.DefaultScalarTypes
import Generated.Test3DefaultNullableScalarsTypes.DefaultNullableScalarTypes


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
      , query = Generated.Test1Objects_and_lists.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test1Objects_and_lists.Query.decoder
      }
    , { id = "test2-default-scalars-types"
      , query = Generated.Test2DefaultScalarsTypes.DefaultScalarTypes.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test2DefaultScalarsTypes.DefaultScalarTypes.decoder
      }
    , { id = "test3-default-nullable-scalars-types"
      , query = Generated.Test3DefaultNullableScalarsTypes.DefaultNullableScalarTypes.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test3DefaultNullableScalarsTypes.DefaultNullableScalarTypes.decoder
      }
    ]  
