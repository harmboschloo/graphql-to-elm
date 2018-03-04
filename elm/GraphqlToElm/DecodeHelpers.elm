module GraphqlToElm.DecodeHelpers
    exposing
        ( andMap
        , emptyObjectDecoder
        , constantDecoder
        )

import Json.Decode as Decode exposing (Decoder)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    Decode.map2 (|>)


emptyObjectDecoder : a -> Decoder a
emptyObjectDecoder result =
    Decode.keyValuePairs Decode.value
        |> Decode.andThen
            (\pairs ->
                if List.isEmpty pairs then
                    Decode.succeed result
                else
                    Decode.fail "expected empty object"
            )


constantDecoder : a -> Decoder a -> Decoder a
constantDecoder constant =
    Decode.andThen
        (\value ->
            if value == constant then
                Decode.succeed value
            else
                Decode.fail <|
                    "expected '"
                        ++ toString constant
                        ++ "' but got '"
                        ++ toString value
                        ++ "`"
        )
