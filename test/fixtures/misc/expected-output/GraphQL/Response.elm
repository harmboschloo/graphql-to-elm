module GraphQL.Response
    exposing
        ( Response(Data, Errors)
        , mapData
        , mapErrors
        , toResult
        , decoder
        )

{-| The GraphQL response type.
See <http://facebook.github.io/graphql/October2016/#sec-Response-Format>.

@docs Response, mapData, mapErrors, toResult, decoder

-}

import Json.Decode as Decode exposing (Decoder)
import GraphQL.Operation as Operation exposing (Operation)
import GraphQL.Optional as Optional exposing (Optional(..))


{-| -}
type Response e a
    = Data a
    | Errors e (Optional a)


{-| Converts the data type of the response.
-}
mapData : (a -> b) -> Response e a -> Response e b
mapData mapper response =
    case response of
        Data data ->
            Data (mapper data)

        Errors errors data ->
            Errors errors <|
                case data of
                    Absent ->
                        Absent

                    Null ->
                        Null

                    Present data ->
                        Present (mapper data)


{-| Converts the errors type of the response.
-}
mapErrors : (e1 -> e2) -> Response e1 a -> Response e2 a
mapErrors mapper response =
    case response of
        Data data ->
            Data data

        Errors errors data ->
            Errors (mapper errors) data


{-| Converts a `Response` to a `Result`.
Note that the optional data in the `Errors` case will be lost.
-}
toResult : Response e a -> Result e a
toResult response =
    case response of
        Data data ->
            Ok data

        Errors errors _ ->
            Err errors


{-| Decoder for the response of an operation.
-}
decoder : Operation t e a -> Decoder (Response e a)
decoder operation =
    Decode.oneOf
        [ Decode.map2 Errors
            (Decode.field "errors" <| Operation.errorsDecoder operation)
            (Optional.fieldDecoder "data" <| Operation.dataDecoder operation)
        , Decode.map Data
            (Decode.field "data" <| Operation.dataDecoder operation)
        ]
