module GraphQL.Helpers.Decode
    exposing
        ( andMap
        , fromResult
        , emptyObject
        , constant
        )

{-| Some additional functions that help with decoding JSON.

@docs andMap, fromResult, constant, emptyObject

-}

import Json.Decode as Decode exposing (Decoder)


{-| Provide a pipeline for mapping decoders.
Can be used for decoding large records.
-}
andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    Decode.map2 (|>)


{-| Turn a result into a decoder.
-}
fromResult : Result String a -> Decoder a
fromResult result =
    case result of
        Err error ->
            Decode.fail error

        Ok value ->
            Decode.succeed value


{-| Decode a constant value.
-}
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


{-| Decode an empty object `{}`.
-}
emptyObject : a -> Decoder a
emptyObject result =
    Decode.keyValuePairs Decode.value
        |> Decode.andThen
            (\pairs ->
                case pairs of
                    [] ->
                        Decode.succeed result

                    _ ->
                        Decode.fail "expected empty object"
            )
