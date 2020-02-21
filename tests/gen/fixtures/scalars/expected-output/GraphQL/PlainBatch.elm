module GraphQL.PlainBatch exposing
    ( Batch, batch, query, mutation
    , map
    , encode, decoder
    )

{-| Batch operations together in one request.
Returns a `Response` for every operation.

    batch (\a b c -> ( a, b, c ))
        |> query operation1
        |> query operation2
        |> mutation operation3

@docs Batch, batch, query, mutation


# Mapping

@docs map


# JSON

@docs encode, decoder

-}

import GraphQL.Helpers.Decode as DecodeHelpers
import GraphQL.Operation as Operation exposing (Mutation, Operation, Query)
import GraphQL.Response as Response exposing (Response)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode


{-| -}
type Batch a
    = Batch
        { operations : List Encode.Value
        , decoder : List Decode.Value -> ( List Decode.Value, Decoder a )
        }


{-| -}
batch : (Response e a -> b) -> Batch (Response e a -> b)
batch a =
    Batch
        { operations = []
        , decoder = \values -> ( values, Decode.succeed a )
        }


{-| -}
query : Operation Query e a -> Batch (Response e a -> b) -> Batch b
query =
    any


{-| -}
mutation : Operation Mutation e a -> Batch (Response e a -> b) -> Batch b
mutation =
    any


any : Operation t e a -> Batch (Response e a -> b) -> Batch b
any operation (Batch state) =
    Batch
        { operations =
            Operation.encode operation :: state.operations
        , decoder =
            \values0 ->
                let
                    ( values1, decoder1 ) =
                        state.decoder values0

                    ( values2, decoder2 ) =
                        responseDecoder operation values1
                in
                ( values2
                , DecodeHelpers.andMap decoder2 decoder1
                )
        }


responseDecoder :
    Operation t e a
    -> (List Decode.Value -> ( List Decode.Value, Decoder (Response e a) ))
responseDecoder operation =
    \values ->
        case values of
            [] ->
                ( values
                , Decode.fail "no more batch responses to decode"
                )

            head :: tail ->
                ( tail
                , head
                    |> decodeValue (Response.decoder operation)
                    |> DecodeHelpers.fromResult
                )


{-| Convert the batch value.
-}
map : (a -> b) -> Batch a -> Batch b
map mapper (Batch state) =
    Batch
        { operations = state.operations
        , decoder = state.decoder >> Tuple.mapSecond (Decode.map mapper)
        }


{-| Encode the batch operations for a request.
-}
encode : Batch a -> Encode.Value
encode (Batch state) =
    Encode.list identity (List.reverse state.operations)


{-| Decoder for the response of a batch request.
-}
decoder : Batch a -> Decoder a
decoder (Batch state) =
    Decode.list Decode.value
        |> Decode.andThen (state.decoder >> Tuple.second)
