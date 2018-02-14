module Data.Binary exposing (Binary, decoder)

import Json.Decode


type Binary
    = Zero
    | One


decoder : Json.Decode.Decoder Binary
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                case string of
                    "ZERO" ->
                        Json.Decode.succeed Zero

                    "ONE" ->
                        Json.Decode.succeed One

                    _ ->
                        Json.Decode.fail <|
                            "Can not convert '"
                                ++ string
                                ++ "' to Binary type"
            )
