module GraphqlToElm.Helpers.Decode
    exposing
        ( andMap
        , fromResult
        , emptyObject
        , constant
        )

import Json.Decode as Decode exposing (Decoder)


andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    Decode.map2 (|>)


fromResult : Result String a -> Decoder a
fromResult result =
    case result of
        Err error ->
            Decode.fail error
        Ok value ->
            Decode.succeed value

emptyObject : a -> Decoder a
emptyObject result =
    Decode.keyValuePairs Decode.value
        |> Decode.andThen
            (\pairs ->
                if List.isEmpty pairs then
                    Decode.succeed result
                else
                    Decode.fail "expected empty object"
            )


constant : a -> Decoder a -> Decoder a
constant constantValue =
    Decode.andThen
        (\value ->
            if value == constantValue then
                Decode.succeed value
            else
                Decode.fail <|
                    "expected '"
                        ++ toString constantValue
                        ++ "' but got '"
                        ++ toString value
                        ++ "`"
        )
