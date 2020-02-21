module GraphQL.Enum.UserType exposing
    ( UserType(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type UserType
    = RegularUser
    | AdminUser
    | Temp_AdminUser


encode : UserType -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder UserType
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown UserType " ++ value)
            )


toString : UserType -> String
toString value =
    case value of
        RegularUser ->
            "REGULAR_USER"

        AdminUser ->
            "ADMIN_USER"

        Temp_AdminUser ->
            "TEMP__ADMIN_USER"


fromString : String -> Maybe UserType
fromString value =
    case value of
        "REGULAR_USER" ->
            Just RegularUser

        "ADMIN_USER" ->
            Just AdminUser

        "TEMP__ADMIN_USER" ->
            Just Temp_AdminUser

        _ ->
            Nothing
