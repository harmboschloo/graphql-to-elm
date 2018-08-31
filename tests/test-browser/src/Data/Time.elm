module Data.Time exposing (Posix, decoder)

import Json.Decode
import Time


type alias Posix =
    Time.Posix


decoder : Json.Decode.Decoder Posix
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\millisString ->
                case String.toInt millisString of
                    Nothing ->
                        Json.Decode.fail
                            ("expect integer but got '" ++ millisString ++ "'")

                    Just millis ->
                        Json.Decode.succeed (Time.millisToPosix millis)
            )
