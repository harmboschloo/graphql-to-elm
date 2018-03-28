module GraphqlToElm.Batch
    exposing
        ( Batch
        , Request
        , Error
        , batch
        , query
        , mutation
        , map
        , post
        , send
        , encode
        , decoder
        )

{-| Batch operations together in one request.

    batch (,,)
        |> query operation1
        |> query operation2
        |> mutation operation3

@docs Batch, batch, query, mutation


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


{-| -}
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


{-| -}
batch : (Response e a -> b) -> Batch (Response e a -> b)
batch a =
    Batch
        { operations = []
        , decoder = (\values -> ( values, Decode.succeed a ))
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
                ( values
                , Decode.fail "no more batch responses to decode"
                )

            head :: tail ->
                ( tail
                , head
                    |> decodeValue (Response.decoder operation)
                    |> DecodeHelpers.fromResult
                )
    )


{-| Convert the batch type.
-}
map : (a -> b) -> Batch a -> Batch b
map mapper (Batch batch) =
    Batch
        { operations = batch.operations
        , decoder = batch.decoder >> Tuple.mapSecond (Decode.map mapper)
        }


{-| Simple helper to create a http post request.
Implemented as:

    post url batch =
        Http.post
            url
            (Http.jsonBody <| encode batch)
            (decoder batch)

-}
post : String -> Batch a -> Request a
post url batch =
    Http.post
        url
        (Http.jsonBody <| encode batch)
        (decoder batch)


{-| The same as `Http.send`.
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
