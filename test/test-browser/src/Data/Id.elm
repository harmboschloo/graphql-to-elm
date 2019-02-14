module Data.Id exposing (Id, decoder)

import Json.Decode


type Id
    = Id String


decoder : Json.Decode.Decoder Id
decoder =
    Json.Decode.map Id Json.Decode.string
