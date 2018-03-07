module GraphqlToElm.Graphql.Operation.Batch
    exposing
        ( Batch
        , map
        , decoder
        , encode
        , batch2
        , batch3
        , batch4
        )

import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode
import GraphqlToElm.Helpers.Decode as DecodeHelpers
import GraphqlToElm.Graphql.Operation as Operation exposing (Operation)
import GraphqlToElm.Graphql.Response as Response exposing (Response)


type Batch a
    = Batch
        { batch : List Encode.Value
        , decoder : Decoder a
        }


map : (a -> b) -> Batch a -> Batch b
map mapper (Batch batch) =
    Batch { batch | decoder = Decode.map mapper batch.decoder }


decoder : Batch a -> Decoder a
decoder (Batch batch) =
    batch.decoder


encode : Batch a -> Encode.Value
encode (Batch batch) =
    Encode.list batch.batch


batch2 :
    (Response e1 a1 -> Response e2 a2 -> b)
    -> Operation e1 a1
    -> Operation e2 a2
    -> Batch b
batch2 mapper op1 op2 =
    Batch
        { batch =
            [ Operation.encode op1
            , Operation.encode op2
            ]
        , decoder =
            valuesDecoder
                (\list ->
                    case list of
                        [ value1, value2 ] ->
                            Decode.map2 mapper
                                (responseDecoder op1 value1)
                                (responseDecoder op2 value2)

                        _ ->
                            failDecoder 2 list
                )
        }


batch3 :
    (Response e1 a1 -> Response e2 a2 -> Response e3 a3 -> b)
    -> Operation e1 a1
    -> Operation e2 a2
    -> Operation e3 a3
    -> Batch b
batch3 mapper op1 op2 op3 =
    Batch
        { batch =
            [ Operation.encode op1
            , Operation.encode op2
            , Operation.encode op3
            ]
        , decoder =
            valuesDecoder
                (\list ->
                    case list of
                        [ value1, value2, value3 ] ->
                            Decode.map3 mapper
                                (responseDecoder op1 value1)
                                (responseDecoder op2 value2)
                                (responseDecoder op3 value3)

                        _ ->
                            failDecoder 3 list
                )
        }


batch4 :
    (Response e1 a1 -> Response e2 a2 -> Response e3 a3 -> Response e4 a4 -> b)
    -> Operation e1 a1
    -> Operation e2 a2
    -> Operation e3 a3
    -> Operation e4 a4
    -> Batch b
batch4 mapper op1 op2 op3 op4 =
    Batch
        { batch =
            [ Operation.encode op1
            , Operation.encode op2
            , Operation.encode op3
            , Operation.encode op4
            ]
        , decoder =
            valuesDecoder
                (\list ->
                    case list of
                        [ value1, value2, value3, value4 ] ->
                            Decode.map4 mapper
                                (responseDecoder op1 value1)
                                (responseDecoder op2 value2)
                                (responseDecoder op3 value3)
                                (responseDecoder op4 value3)

                        _ ->
                            failDecoder 4 list
                )
        }


valuesDecoder : (List Decode.Value -> Decoder a) -> Decoder a
valuesDecoder toDecoder =
    Decode.andThen toDecoder (Decode.list Decode.value)


responseDecoder : Operation e a -> Decode.Value -> Decoder (Response e a)
responseDecoder operation value =
    value
        |> decodeValue (Response.decoder operation)
        |> DecodeHelpers.fromResult


failDecoder : Int -> List Decode.Value -> Decoder a
failDecoder n list =
    Decode.fail <|
        "expected list with "
            ++ toString n
            ++ " items but got "
            ++ toString (List.length list)
