module GraphqlToElm.DecodeHelpers exposing (andMap, emptyObjectDecoder)

import Json.Decode as Decode exposing (Decoder)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    Decode.map2 (|>)


emptyObjectDecoder : Decoder {}
emptyObjectDecoder =
    Decode.keyValuePairs Decode.value
        |> Decode.andThen
            (\pairs ->
                if List.isEmpty pairs then
                    Decode.succeed {}
                else
                    Decode.fail "expected empty object"
            )
