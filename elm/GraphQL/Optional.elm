module GraphQL.Optional
    exposing
        ( Optional(Present, Null, Absent)
        , map
        , withDefault
        , toMaybe
        , fromMaybe
        , encode
        , encodeList
        , encodeObject
        , fieldDecoder
        , nonNullFieldDecoder
        )

{-| An `Optional` can be `Present`, `Null` or `Absent`.

@docs Optional, map, withDefault, toMaybe, fromMaybe


# Encode

@docs encode, encodeList, encodeObject


# Decode

@docs fieldDecoder, nonNullFieldDecoder

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


{-| -}
type Optional a
    = Present a
    | Null
    | Absent


{-| -}
map : (a -> b) -> Optional a -> Optional b
map mapper optional =
    case optional of
        Present a ->
            Present (mapper a)

        Null ->
            Null

        Absent ->
            Absent


{-| -}
withDefault : a -> Optional a -> a
withDefault default optional =
    case optional of
        Present a ->
            a

        _ ->
            default


{-| -}
toMaybe : Optional a -> Maybe a
toMaybe optional =
    case optional of
        Present a ->
            Just a

        _ ->
            Nothing


{-| -}
fromMaybe : Maybe a -> Optional a -> Optional a
fromMaybe maybe default =
    case maybe of
        Just a ->
            Present a

        Nothing ->
            default



-- Encode


{-| Encode an `Optional` value.
-}
encode : (a -> Encode.Value) -> Optional a -> Maybe Encode.Value
encode encoder optional =
    case optional of
        Present a ->
            Just (encoder a)

        Null ->
            Just Encode.null

        Absent ->
            Nothing


{-| Encode a list of `Optional` values. Absent values are omitted.
-}
encodeList : (a -> Encode.Value) -> List (Optional a) -> Encode.Value
encodeList encoder optionals =
    optionals
        |> List.filterMap (encode encoder)
        |> Encode.list


{-| Encode a object of `Optional` fields. Absent fields are omitted.
-}
encodeObject : List ( String, Optional Encode.Value ) -> Encode.Value
encodeObject optionalFields =
    optionalFields
        |> List.filterMap
            (\( name, optionalValue ) ->
                optionalValue
                    |> encode identity
                    |> Maybe.map (\value -> ( name, value ))
            )
        |> Encode.object



-- Decode


{-| Decode a JSON object with a `Optional` field.
-}
fieldDecoder : String -> Decoder a -> Decoder (Optional a)
fieldDecoder name decoder =
    Decode.maybe (Decode.field name Decode.value)
        |> Decode.andThen
            (Maybe.map (valueToOptionalDecoder decoder)
                >> Maybe.withDefault (Decode.succeed Absent)
            )


valueToOptionalDecoder : Decoder a -> Decode.Value -> Decoder (Optional a)
valueToOptionalDecoder decoder value =
    case Decode.decodeValue (Decode.nullable decoder) value of
        Err error ->
            Decode.fail error

        Ok Nothing ->
            Decode.succeed Null

        Ok (Just a) ->
            Decode.succeed (Present a)


{-| Decode a JSON object with a `Optional` field that can be present or absent
but not `null`.
-}
nonNullFieldDecoder : String -> Decoder a -> Decoder (Maybe a)
nonNullFieldDecoder name decoder =
    Decode.maybe (Decode.field name Decode.value)
        |> Decode.andThen
            (Maybe.map (valueToMaybeDecoder decoder)
                >> Maybe.withDefault (Decode.succeed Nothing)
            )


valueToMaybeDecoder : Decoder a -> Decode.Value -> Decoder (Maybe a)
valueToMaybeDecoder decoder value =
    case Decode.decodeValue decoder value of
        Err error ->
            Decode.fail error

        Ok a ->
            Decode.succeed (Just a)
