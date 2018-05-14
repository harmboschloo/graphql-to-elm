module GraphQL.Optional.Encode
    exposing
        ( optional
        , list
        , object
        )

{-| Encode [`Optionals`](# GraphQL.Optional.Optional) to JSON.

@docs optional, list, object

-}

import Json.Encode as Encode
import GraphQL.Optional exposing (Optional(Absent, Null, Present))


{-| Encode an `Optional` value.
-}
optional : (a -> Encode.Value) -> Optional a -> Maybe Encode.Value
optional encoder optional =
    case optional of
        Present a ->
            Just (encoder a)

        Null ->
            Just Encode.null

        Absent ->
            Nothing


{-| Encode a list of `Optional` values. Absent values are omitted.
-}
list : (a -> Encode.Value) -> List (Optional a) -> Encode.Value
list encoder optionals =
    optionals
        |> List.filterMap (optional encoder)
        |> Encode.list


{-| Encode a object of `Optional` fields. Absent fields are omitted.
-}
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
