module GraphqlToElm.OptionalInput
    exposing
        ( OptionalInput(..)
        , map
        , encode
        , encodeList
        , encodeObject
        )

import Json.Encode


type OptionalInput a
    = Present a
    | Null
    | Absent


map : (a -> b) -> OptionalInput a -> OptionalInput b
map mapper optional =
    case optional of
        Present a ->
            Present (mapper a)

        Null ->
            Null

        Absent ->
            Absent


encode : (a -> Json.Encode.Value) -> OptionalInput a -> Maybe Json.Encode.Value
encode encoder optional =
    case optional of
        Present a ->
            Just (encoder a)

        Null ->
            Just Json.Encode.null

        Absent ->
            Nothing


encodeList :
    (a -> Json.Encode.Value)
    -> List (OptionalInput a)
    -> Json.Encode.Value
encodeList encoder list =
    list
        |> List.filterMap (encode encoder)
        |> Json.Encode.list


encodeObject :
    List ( String, OptionalInput Json.Encode.Value )
    -> Json.Encode.Value
encodeObject fields =
    fields
        |> List.filterMap
            (\( name, optionalValue ) ->
                optionalValue
                    |> encode identity
                    |> Maybe.map (\value -> ( name, value ))
            )
        |> Json.Encode.object
