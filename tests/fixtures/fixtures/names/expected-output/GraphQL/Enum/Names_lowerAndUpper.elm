module GraphQL.Enum.Names_lowerAndUpper
    exposing
        ( Names_lowerAndUpper(..)
        , encode
        , decoder
        , toString
        , fromString
        )

import Json.Decode
import Json.Encode


type Names_lowerAndUpper
    = OneAndTwo
    | TwoOrTwenty_even
    | FourtyTwo


encode : Names_lowerAndUpper -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder Names_lowerAndUpper
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown Names_lowerAndUpper " ++ value)
            )


toString : Names_lowerAndUpper -> String
toString value =
    case value of
        OneAndTwo ->
            "oneAndTwo"

        TwoOrTwenty_even ->
            "twoOrTwenty_even"

        FourtyTwo ->
            "fourtyTwo"


fromString : String -> Maybe Names_lowerAndUpper
fromString value =
    case value of
        "oneAndTwo" ->
            Just OneAndTwo

        "twoOrTwenty_even" ->
            Just TwoOrTwenty_even

        "fourtyTwo" ->
            Just FourtyTwo

        _ ->
            Nothing
