module Data.Date exposing (Date, decoder)

import Date
import Json.Decode


type alias Date =
    Date.Date

decoder : Json.Decode.Decoder Date
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\dateString ->
                case Date.fromString dateString of
                    Err error ->
                        Json.Decode.fail error

                    Ok date ->
                        Json.Decode.succeed date
            )
