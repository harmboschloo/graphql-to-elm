module GraphqlToElm.Batch
    exposing
        ( Batch
        , Request
        , Error
        , batch
        , query
        , mutation
        , map
        , mapError
        , post
        , send
        , encode
        , decoder
        )

{-| Batch operations together in one request.

    send BatchReceived <|
        post "/graphql" <|
            (batch (,,)
                |> query operation1
                |> query operation2
                |> mutation operation3
            )

Sending a batch returns `Result` of the combined data
or the errors of one of the queries.


# Batch

@docs Batch, batch, query, mutation


# Mapping

@docs map, mapError


# Http

@docs Request, Error, post, send


# JSON

@docs encode, decoder

-}

import Http
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode
import GraphqlToElm.Helpers.Decode as DecodeHelpers
import GraphqlToElm.Operation as Operation exposing (Operation, Query, Mutation)
import GraphqlToElm.Response as Response exposing (Response)


{-| -}
type Batch e a
    = Batch
        { operations : List Encode.Value
        , decoder :
            List Decode.Value -> ( List Decode.Value, Decoder (Result e a) )
        }


{-| -}
type alias Request a =
    Http.Request a


{-| -}
type alias Error =
    Http.Error


{-| -}
batch : (a -> b) -> Batch e (a -> b)
batch a =
    Batch
        { operations = []
        , decoder = (\values -> ( values, Decode.succeed (Ok a) ))
        }


{-| -}
query : Operation Query e a -> Batch e (a -> b) -> Batch e b
query =
    any


{-| -}
mutation : Operation Mutation e a -> Batch e (a -> b) -> Batch e b
mutation =
    any


any : Operation t e a -> Batch e (a -> b) -> Batch e b
any operation (Batch batch) =
    Batch
        { operations =
            Operation.encode operation :: batch.operations
        , decoder =
            (\values0 ->
                let
                    ( values1, decoder1 ) =
                        batch.decoder values0

                    ( values2, decoder2 ) =
                        responseDecoder operation values1
                in
                    ( values2
                    , Decode.map2 andMapResult decoder2 decoder1
                    )
            )
        }


andMapResult : Result e a -> Result e (a -> b) -> Result e b
andMapResult =
    Result.map2 (|>)


responseDecoder :
    Operation t e a
    -> (List Decode.Value -> ( List Decode.Value, Decoder (Result e a) ))
responseDecoder operation =
    (\values ->
        case values of
            [] ->
                ( values
                , Decode.fail "no more batch responses to decode"
                )

            head :: tail ->
                ( tail
                , head
                    |> decodeValue
                        (Response.decoder operation
                            |> Decode.map Response.toResult
                        )
                    |> DecodeHelpers.fromResult
                )
    )


{-| Convert the batch data value.
-}
map : (a -> b) -> Batch e a -> Batch e b
map mapper (Batch batch) =
    Batch
        { operations = batch.operations
        , decoder =
            batch.decoder >> Tuple.mapSecond (Decode.map <| Result.map mapper)
        }


{-| Convert the batch error value.
-}
mapError : (e1 -> e2) -> Batch e1 a -> Batch e2 a
mapError mapper (Batch batch) =
    Batch
        { operations = batch.operations
        , decoder =
            batch.decoder
                >> Tuple.mapSecond (Decode.map <| Result.mapError mapper)
        }


{-| Simple helper to create a http post request.
Implemented as:

    post url batch =
        Http.post
            url
            (Http.jsonBody <| encode batch)
            (decoder batch)

-}
post : String -> Batch e a -> Request (Result e a)
post url batch =
    Http.post
        url
        (Http.jsonBody <| encode batch)
        (decoder batch)


{-| The same as `Http.send`.
-}
send : (Result Error (Result e a) -> msg) -> Request (Result e a) -> Cmd msg
send =
    Http.send


{-| Encode the batch operations for a request.
-}
encode : Batch e a -> Encode.Value
encode (Batch batch) =
    Encode.list (List.reverse batch.operations)


{-| Decoder for the response of a batch request.
-}
decoder : Batch e a -> Decoder (Result e a)
decoder (Batch batch) =
    Decode.list Decode.value
        |> Decode.andThen (batch.decoder >> Tuple.second)
