module GraphqlToElm.DecodeHelpers exposing (andMap)

import Json.Decode exposing (Decoder, map2)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    map2 (|>)
