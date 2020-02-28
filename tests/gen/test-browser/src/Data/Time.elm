module Data.Time exposing (Posix, decoder, encode)

import Json.Decode
import Json.Encode
import Time


type alias Posix =
    Time.Posix


encode : Posix -> Json.Encode.Value
encode =
    Time.posixToMillis >> String.fromInt >> Json.Encode.string


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
