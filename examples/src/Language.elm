module Language
    exposing
        ( Language(..)
        , toString
        , fromString
        , encode
        , decoder
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Language
    = En
    | Nl


toString : Language -> String
toString value =
    case value of
        En ->
            "EN"

        Nl ->
            "NL"


fromString : String -> Maybe Language
fromString value =
    case value of
        "EN" ->
            Just En

        "NL" ->
            Just Nl

        _ ->
            Nothing


encode : Language -> Encode.Value
encode value =
    Encode.string (toString value)


decoder : Decoder Language
decoder =
    Decode.string
        |> Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Decode.succeed
                    |> Maybe.withDefault
                        (Decode.fail <|
                            "unknown Language "
                                ++ value
                        )
            )
