module GraphqlToElm.Optional
    exposing
        ( Optional(..)
        , map
        , toMaybe
        , fieldDecoder
        , encode
        , encodeList
        , encodeObject
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Optional a
    = Present a
    | Null
    | Absent


map : (a -> b) -> Optional a -> Optional b
map mapper optional =
    case optional of
        Present a ->
            Present (mapper a)

        Null ->
            Null

        Absent ->
            Absent


toMaybe : Optional a -> Maybe a
toMaybe optional =
    case optional of
        Present a ->
            Just a

        _ ->
            Nothing


fieldDecoder : String -> Decoder a -> Decoder (Optional a)
fieldDecoder field aDecoder =
    Decode.maybe (Decode.field field Decode.value)
        |> Decode.andThen
            (Maybe.map (parseDecodedValue aDecoder)
                >> Maybe.withDefault (Decode.succeed Absent)
            )


parseDecodedValue : Decoder a -> Decode.Value -> Decoder (Optional a)
parseDecodedValue aDecoder value =
    case Decode.decodeValue (Decode.nullable aDecoder) value of
        Err error ->
            Decode.fail error

        Ok Nothing ->
            Decode.succeed Null

        Ok (Just a) ->
            Decode.succeed (Present a)


encode : (a -> Decode.Value) -> Optional a -> Maybe Encode.Value
encode encoder optional =
    case optional of
        Present a ->
            Just (encoder a)

        Null ->
            Just Encode.null

        Absent ->
            Nothing


encodeList : (a -> Encode.Value) -> List (Optional a) -> Encode.Value
encodeList encoder list =
    list
        |> List.filterMap (encode encoder)
        |> Encode.list


encodeObject : List ( String, Optional Encode.Value ) -> Encode.Value
encodeObject fields =
    fields
        |> List.filterMap
            (\( name, optionalValue ) ->
                optionalValue
                    |> encode identity
                    |> Maybe.map (\value -> ( name, value ))
            )
        |> Encode.object
