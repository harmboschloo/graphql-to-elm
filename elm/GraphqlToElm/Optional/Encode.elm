module GraphqlToElm.Optional.Encode
    exposing
        ( optional
        , list
        , object
        )

import Json.Encode as Encode
import GraphqlToElm.Optional exposing (Optional(Absent, Null, Present))


optional : (a -> Encode.Value) -> Optional a -> Maybe Encode.Value
optional encoder optional =
    case optional of
        Present a ->
            Just (encoder a)

        Null ->
            Just Encode.null

        Absent ->
            Nothing


list : (a -> Encode.Value) -> List (Optional a) -> Encode.Value
list encoder optionals =
    optionals
        |> List.filterMap (optional encoder)
        |> Encode.list


object : List ( String, Optional Encode.Value ) -> Encode.Value
object optionalFields =
    optionalFields
        |> List.filterMap
            (\( name, optionalValue ) ->
                optionalValue
                    |> optional identity
                    |> Maybe.map (\value -> ( name, value ))
            )
        |> Encode.object
