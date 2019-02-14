module GraphQL.Enum.Names_lower exposing
    ( Names_lower(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type Names_lower
    = One
    | Two
    | Fourty_two


encode : Names_lower -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder Names_lower
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown Names_lower " ++ value)
            )


toString : Names_lower -> String
toString value =
    case value of
        One ->
            "one"

        Two ->
            "two"

        Fourty_two ->
            "fourty_two"


fromString : String -> Maybe Names_lower
fromString value =
    case value of
        "one" ->
            Just One

        "two" ->
            Just Two

        "fourty_two" ->
            Just Fourty_two

        _ ->
            Nothing
