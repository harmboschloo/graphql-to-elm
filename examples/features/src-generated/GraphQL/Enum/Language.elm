module GraphQL.Enum.Language
    exposing
        ( Language(..)
        , encode
        , decoder
        , toString
        , fromString
        )

import Json.Decode
import Json.Encode


type Language
    = En
    | Nl


encode : Language -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder Language
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown Language " ++ value)
            )


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
