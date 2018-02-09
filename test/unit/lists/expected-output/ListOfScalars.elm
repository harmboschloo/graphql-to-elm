module ListOfScalars exposing (Data, decoder, query)

import Json.Decode


query : String
query =
    """{
  pets_pet

  pets_petOrNull

  petsOrNull_pet

  petsOrNull_petOrNull
}"""


type alias Data =
    { petsOrNull_pet : Maybe (List String)
    , petsOrNull_petOrNull : Maybe (List (Maybe String))
    , pets_pet : List String
    , pets_petOrNull : List (Maybe String)
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map4 Data
        (Json.Decode.field "petsOrNull_pet" (Json.Decode.nullable (Json.Decode.list Json.Decode.string)))
        (Json.Decode.field "petsOrNull_petOrNull" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable Json.Decode.string))))
        (Json.Decode.field "pets_pet" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "pets_petOrNull" (Json.Decode.list (Json.Decode.nullable Json.Decode.string)))
