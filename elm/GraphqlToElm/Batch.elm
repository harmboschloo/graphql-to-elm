module GraphqlToElm.Batch
    exposing
        ( Batch
        , Request
        , Error
        , map
        , query
        , mutation
        , andQuery
        , andMutation
        , post
        , send
        , encode
        , decoder
        )

{-| Batch operations together in one request.

    query (,,) operation1
        |> andQuery operation2
        |> andMutation operation3

@docs Batch, query, mutation, andQuery, andMutation


# Mapping

@docs map


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


{-| A `Operations` batch.
-}
type Batch a
    = Batch
        { operations : List Encode.Value
        , decoder : List Decode.Value -> ( List Decode.Value, Decoder a )
        }


{-| -}
type alias Request a =
    Http.Request a


{-| -}
type alias Error =
    Http.Error


{-| Convert the batch type.
-}
map : (a -> b) -> Batch a -> Batch b
map mapper (Batch batch) =
    Batch
        { operations = batch.operations
        , decoder =
            (\values0 ->
                let
                    ( values1, decoder1 ) =
                        batch.decoder values0
                in
                    ( values1, Decode.map mapper decoder1 )
            )
        }


{-| Create a batch from a query operation.

    query (,) operation1
        |> andQuery operation2

-}
query : (Response e a -> b) -> Operation Query e a -> Batch b
query =
    any


{-| Create a batch from a mutation operation.

    mutation (,) operation1
        |> andQuery operation2

-}
mutation : (Response e a -> b) -> Operation Mutation e a -> Batch b
mutation =
    any


any : (Response e a -> b) -> Operation t e a -> Batch b
any mapper operation =
    Batch
        { operations =
            [ Operation.encode operation ]
        , decoder =
            (\values0 ->
                responseDecoder operation values0
                    |> Tuple.mapSecond (Decode.map mapper)
            )
        }


{-| Add a query operation to the batch.

    query (,) operation1
        |> andQuery operation2

-}
andQuery : Operation Query e a -> Batch (Response e a -> b) -> Batch b
andQuery =
    andAny


{-| Add a mutation operation to the batch.

    query (,) operation1
        |> andMutation operation2

-}
andMutation : Operation Mutation e a -> Batch (Response e a -> b) -> Batch b
andMutation =
    andAny


andAny : Operation t e a -> Batch (Response e a -> b) -> Batch b
andAny operation (Batch batch) =
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
                    , DecodeHelpers.andMap decoder2 decoder1
                    )
            )
        }


responseDecoder :
    Operation t e a
    -> (List Decode.Value -> ( List Decode.Value, Decoder (Response e a) ))
responseDecoder operation =
    (\values ->
        case values of
            [] ->
                ( []
                , Decode.fail "no more batch responses to decode"
                )

            head :: tail ->
                ( tail
                , head
                    |> decodeValue (Response.decoder operation)
                    |> DecodeHelpers.fromResult
                )
    )


{-| Create a post request to an url.
-}
post : String -> Batch a -> Request a
post url batch =
    Http.post
        url
        (Http.jsonBody <| encode batch)
        (decoder batch)


{-| Send a http requst.
-}
send : (Result Error a -> msg) -> Request a -> Cmd msg
send =
    Http.send


{-| Encode the batch operations for a request.
-}
encode : Batch a -> Encode.Value
encode (Batch batch) =
    Encode.list (List.reverse batch.operations)


{-| Decoder for the response of a batch request.
-}
decoder : Batch a -> Decoder a
decoder (Batch batch) =
    Decode.list Decode.value
        |> Decode.andThen (batch.decoder >> Tuple.second)
