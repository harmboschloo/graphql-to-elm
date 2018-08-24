module GraphQL.Enum.TypeKind__
    exposing
        ( TypeKind__(..)
        , encode
        , decoder
        , toString
        , fromString
        )

import Json.Decode
import Json.Encode


type TypeKind__
    = Scalar
    | Object
    | Interface
    | Union
    | Enum
    | InputObject
    | List
    | NonNull


encode : TypeKind__ -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder TypeKind__
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown TypeKind__ " ++ value)
            )


toString : TypeKind__ -> String
toString value =
    case value of
        Scalar ->
            "SCALAR"

        Object ->
            "OBJECT"

        Interface ->
            "INTERFACE"

        Union ->
            "UNION"

        Enum ->
            "ENUM"

        InputObject ->
            "INPUT_OBJECT"

        List ->
            "LIST"

        NonNull ->
            "NON_NULL"


fromString : String -> Maybe TypeKind__
fromString value =
    case value of
        "SCALAR" ->
            Just Scalar

        "OBJECT" ->
            Just Object

        "INTERFACE" ->
            Just Interface

        "UNION" ->
            Just Union

        "ENUM" ->
            Just Enum

        "INPUT_OBJECT" ->
            Just InputObject

        "LIST" ->
            Just List

        "NON_NULL" ->
            Just NonNull

        _ ->
            Nothing
