module ScalarVariable exposing (Data, User, Variables, decoder, encodeVariables, query)

import Json.Decode
import Json.Encode


query : String
query =
    """query ScalarVariables($id: String!) {
  user(id: $id) {
    name
  }
}"""


type alias Variables =
    { id : String
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables variables =
    Json.Encode.object
        [ ( "id", Json.Encode.string variables.id )
        ]


type alias User =
    { name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map User
        (Json.Decode.field "name" Json.Decode.string)


type alias Data =
    { user : Maybe User
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "user" (Json.Decode.nullable userDecoder))
