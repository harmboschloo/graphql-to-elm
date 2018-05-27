module GraphQL.Enum.NamesUpper
    exposing
        ( NamesUpper(..)
        , encode
        , decoder
        , toString
        , fromString
        )

import Json.Decode
import Json.Encode


type NamesUpper
    = One
    | Two
    | FourtyTwo


encode : NamesUpper -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder NamesUpper
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown NamesUpper " ++ value)
            )


toString : NamesUpper -> String
toString value =
    case value of
        One ->
            "ONE"

        Two ->
            "TWO"

        FourtyTwo ->
            "FOURTY_TWO"


fromString : String -> Maybe NamesUpper
fromString value =
    case value of
        "ONE" ->
            Just One

        "TWO" ->
            Just Two

        "FOURTY_TWO" ->
            Just FourtyTwo

        _ ->
            Nothing
