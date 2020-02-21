module GraphQL.Helpers.Decode exposing (andMap, fromResult, constantString, emptyObject)

{-| Some additional functions that help with decoding JSON.

@docs andMap, fromResult, constantString, emptyObject

-}

import Json.Decode as Decode exposing (Decoder, Error)


{-| Provide a pipeline for mapping decoders.
Can be used for decoding large records.
-}
andMap : Decoder a -> Decoder (a -> b) -> Decoder b
andMap =
    Decode.map2 (|>)


{-| Turn a decode result into a decoder.
-}
fromResult : Result Error a -> Decoder a
fromResult result =
    case result of
        Err error ->
            Decode.fail (Decode.errorToString error)

        Ok value ->
            Decode.succeed value


{-| Decode a constant string.
-}
constantString : String -> Decoder String
constantString constantValue =
    Decode.string
        |> Decode.andThen
            (\value ->
                if value == constantValue then
                    Decode.succeed value

                else
                    Decode.fail <|
                        "expected '"
                            ++ constantValue
                            ++ "' but got '"
                            ++ value
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
