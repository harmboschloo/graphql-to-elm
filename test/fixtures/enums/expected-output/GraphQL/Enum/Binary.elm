module GraphQL.Enum.Binary exposing
    ( Binary(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type Binary
    = Zero
    | One


encode : Binary -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder Binary
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown Binary " ++ value)
            )


toString : Binary -> String
toString value =
    case value of
        Zero ->
            "ZERO"

        One ->
            "ONE"


fromString : String -> Maybe Binary
fromString value =
    case value of
        "ZERO" ->
            Just Zero

        "ONE" ->
            Just One

        _ ->
            Nothing
