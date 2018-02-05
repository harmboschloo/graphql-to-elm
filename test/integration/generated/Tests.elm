module Generated.Tests exposing (requests)

import Json.Encode


requests : List { id : String, body : Json.Encode.Value }
requests =
    [ { id = "misc"
      , body =
            Json.Encode.object
                [ ( "query", Json.Encode.string "{ i { name } }" )
                , ( "variables", Json.Encode.string "{}" )
                ]
      }
    ]
