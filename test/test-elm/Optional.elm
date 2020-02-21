module Optional exposing (suite)

import Expect exposing (Expectation, equal, fail)
import GraphQL.Optional exposing (Optional(..), fieldDecoder, nonNullFieldDecoder)
import Json.Decode as Decode exposing (Decoder, decodeString)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Graphql.Optional"
        [ describe "fieldDecoder"
            [ test "absent" <|
                expectDecodeOk
                    (fieldDecoder "number" Decode.int)
                    "{}"
                    Absent
            , test "null" <|
                expectDecodeOk
                    (fieldDecoder "number" Decode.int)
                    "{\"number\": null}"
                    Null
            , test "present" <|
                expectDecodeOk
                    (fieldDecoder "number" Decode.int)
                    "{\"number\": 123}"
                    (Present 123)
            , test "wrong type" <|
                expectDecodeErr
                    (fieldDecoder "number" Decode.int)
                    "{\"number\": \"123\"}"
            ]
        , describe "nonNullFieldDecoder"
            [ test "absent" <|
                expectDecodeOk
                    (nonNullFieldDecoder "number" Decode.int)
                    "{}"
                    Nothing
            , test "not null" <|
                expectDecodeErr
                    (nonNullFieldDecoder "number" Decode.int)
                    "{\"number\": null}"
            , test "present" <|
                expectDecodeOk
                    (nonNullFieldDecoder "number" Decode.int)
                    "{\"number\": 123}"
                    (Just 123)
            , test "wrong type" <|
                expectDecodeErr
                    (nonNullFieldDecoder "number" Decode.int)
                    "{\"number\": \"123\"}"
            ]
        ]


expectDecodeOk : Decoder a -> String -> a -> (() -> Expectation)
expectDecodeOk decoder json expectedValue =
    \_ ->
        case decodeString decoder json of
            Ok value ->
                equal expectedValue value

            Err error ->
                fail (Decode.errorToString error)


expectDecodeErr : Decoder a -> String -> (() -> Expectation)
expectDecodeErr decoder json =
    \_ ->
        decodeString decoder json
            |> Expect.err
