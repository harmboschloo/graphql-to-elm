module GraphqlToElm.Optional.Decode exposing (field, nonNullField)

import Json.Decode as Decode exposing (Decoder)
import GraphqlToElm.Optional exposing (Optional(Absent, Null, Present))


field : String -> Decoder a -> Decoder (Optional a)
field name decoder =
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


nonNullField : String -> Decoder a -> Decoder (Maybe a)
nonNullField name decoder =
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
