module Generated.Test1LineEndingsCrlf.Crlf exposing (Data, decoder, query)

import Json.Decode


query : String
query =
    """{
  hello
}"""


type alias Data =
    { hello : String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "hello" Json.Decode.string)
