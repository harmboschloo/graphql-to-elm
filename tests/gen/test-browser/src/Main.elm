module Main exposing (main)

import Browser exposing (Document)
import GraphQL.Batch as Batch exposing (Batch)
import GraphQL.Http
    exposing
        ( getQuery
        , postBatch
        , postMutation
        , postPlainBatch
        , postQuery
        )
import GraphQL.Operation exposing (Mutation, Query)
import GraphQL.PlainBatch as PlainBatch
import GraphQL.Response as Response exposing (Response(..))
import Html
import Http
import Set
import Tests exposing (Test, mutationTests, queryTests)


numberOfRounds : Int
numberOfRounds =
    100


postQueryTests : List (Test Query)
postQueryTests =
    queryTests
        |> List.repeat numberOfRounds
        |> List.concat


postMutationTests : List (Test Mutation)
postMutationTests =
    mutationTests
        |> List.repeat numberOfRounds
        |> List.concat


schemaIds : List String
schemaIds =
    [ List.map .schemaId queryTests
    , List.map .schemaId mutationTests
    ]
        |> List.concat
        |> Set.fromList
        |> Set.toList


testsBySchema : List ( String, List (Test Query), List (Test Mutation) )
testsBySchema =
    schemaIds
        |> List.map
            (\schemaId ->
                ( schemaId
                , List.filter (\test -> test.schemaId == schemaId) queryTests
                , List.filter (\test -> test.schemaId == schemaId) mutationTests
                )
            )


batchTests : List ( String, String, Batch String (List String) )
batchTests =
    let
        batch2 a b =
            [ Debug.toString a, Debug.toString b ]

        batch3 a b c =
            [ Debug.toString a, Debug.toString b, Debug.toString c ]
    in
    testsBySchema
        |> List.map
            (\( schemaId, queryTests, mutationTests ) ->
                List.concat
                    [ List.map2
                        (\a b ->
                            ( schemaId
                            , id2 a b
                            , Batch.batch batch2
                                |> Batch.query a.operation
                                |> Batch.query b.operation
                            )
                        )
                        queryTests
                        (List.reverse queryTests)
                    , List.map3
                        (\a b c ->
                            ( schemaId
                            , id3 a b c
                            , Batch.batch batch3
                                |> Batch.query a.operation
                                |> Batch.mutation b.operation
                                |> Batch.query c.operation
                            )
                        )
                        queryTests
                        mutationTests
                        (List.reverse queryTests)
                    , List.map2
                        (\a b ->
                            ( schemaId
                            , id2 a b
                            , Batch.batch batch2
                                |> Batch.mutation a.operation
                                |> Batch.mutation b.operation
                            )
                        )
                        (List.reverse mutationTests)
                        mutationTests
                    ]
            )
        |> List.concat


type alias PlainBatchData =
    List (Response String String)


plainBatchTests : List ( String, String, PlainBatch.Batch PlainBatchData )
plainBatchTests =
    let
        map =
            Response.mapData Debug.toString >> Response.mapErrors Debug.toString

        batch2 a b =
            [ map a, map b ]

        batch3 a b c =
            [ map a, map b, map c ]
    in
    testsBySchema
        |> List.map
            (\( schemaId, queryTests, mutationTests ) ->
                List.concat
                    [ List.map2
                        (\a b ->
                            ( schemaId
                            , id2 a b
                            , PlainBatch.batch batch2
                                |> PlainBatch.query a.operation
                                |> PlainBatch.query b.operation
                            )
                        )
                        queryTests
                        (List.reverse queryTests)
                    , List.map3
                        (\a b c ->
                            ( schemaId
                            , id3 a b c
                            , PlainBatch.batch batch3
                                |> PlainBatch.query a.operation
                                |> PlainBatch.mutation b.operation
                                |> PlainBatch.query c.operation
                            )
                        )
                        queryTests
                        mutationTests
                        (List.reverse queryTests)
                    , List.map2
                        (\a b ->
                            ( schemaId
                            , id2 a b
                            , PlainBatch.batch batch2
                                |> PlainBatch.mutation a.operation
                                |> PlainBatch.mutation b.operation
                            )
                        )
                        (List.reverse mutationTests)
                        mutationTests
                    ]
            )
        |> List.concat


id2 : { a | id : String } -> { b | id : String } -> String
id2 a b =
    "[" ++ String.join "," [ a.id, b.id ] ++ "]"


id3 : { a | id : String } -> { b | id : String } -> { c | id : String } -> String
id3 a b c =
    "[" ++ String.join "," [ a.id, b.id, c.id ] ++ "]"


getTests : List (Test Query)
getTests =
    queryTests
        |> List.repeat numberOfRounds
        |> List.concat


numberOfTests : Int
numberOfTests =
    List.length postQueryTests
        + List.length postMutationTests
        + List.length batchTests
        + List.length plainBatchTests
        + List.length getTests



-- Model


type alias Model =
    { passed : Int
    , failed : Int
    }


testsDone : Model -> Int
testsDone model =
    model.passed + model.failed


init : () -> ( Model, Cmd Msg )
init _ =
    let
        _ =
            Debug.log "[Start Test] number of tests" numberOfTests
    in
    ( Model 0 0
    , [ List.map sendPostQuery postQueryTests
      , List.map sendPostMutation postMutationTests
      , List.map sendBatch batchTests
      , List.map sendPlainBatch plainBatchTests
      , List.map sendGet getTests
      ]
        |> List.concat
        |> Cmd.batch
    )


sendPostQuery : Test Query -> Cmd Msg
sendPostQuery test =
    Http.send (TestResponseReceived test.id) <|
        postQuery ("/graphql/" ++ test.schemaId) test.operation


sendPostMutation : Test Mutation -> Cmd Msg
sendPostMutation test =
    Http.send (TestResponseReceived test.id) <|
        postMutation ("/graphql/" ++ test.schemaId) test.operation


sendBatch : ( String, String, Batch String (List String) ) -> Cmd Msg
sendBatch ( schemaId, id, batch ) =
    Http.send (TestBatchResponseReceived id) <|
        postBatch ("/graphql/" ++ schemaId) batch


sendPlainBatch : ( String, String, PlainBatch.Batch PlainBatchData ) -> Cmd Msg
sendPlainBatch ( schemaId, id, batch ) =
    Http.send (TestPlainBatchResponseReceived id) <|
        postPlainBatch ("/graphql/" ++ schemaId) batch


sendGet : Test Query -> Cmd Msg
sendGet test =
    Http.send (TestResponseReceived test.id) <|
        getQuery ("/graphql/" ++ test.schemaId) test.operation



-- Update


type Msg
    = TestResponseReceived String (Result Http.Error (Response String String))
    | TestBatchResponseReceived String (Result Http.Error (Result String (List String)))
    | TestPlainBatchResponseReceived String (Result Http.Error PlainBatchData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TestResponseReceived id (Ok (Data data)) ->
            passed id data model

        TestResponseReceived id (Ok (Errors errors data)) ->
            failed id
                ("Errors: " ++ Debug.toString { errors = errors, data = data })
                model

        TestResponseReceived id (Err error) ->
            failed id ("HttpError: " ++ Debug.toString error) model

        TestBatchResponseReceived id (Ok dataResult) ->
            case dataResult of
                Err errors ->
                    failed id ("Errors: " ++ errors) model

                Ok data ->
                    passed id (Debug.toString data) model

        TestBatchResponseReceived id (Err error) ->
            failed id ("HttpError: " ++ Debug.toString error) model

        TestPlainBatchResponseReceived id (Ok data) ->
            data
                |> List.filterMap
                    (\response ->
                        case response of
                            Response.Errors errors _ ->
                                Just errors

                            Response.Data _ ->
                                Nothing
                    )
                |> List.head
                |> Maybe.map (\errors -> failed id ("Errors: " ++ errors) model)
                |> Maybe.withDefault (passed id (Debug.toString data) model)

        TestPlainBatchResponseReceived id (Err error) ->
            failed id ("HttpError: " ++ Debug.toString error) model


passed : String -> String -> Model -> ( Model, Cmd Msg )
passed id data model =
    let
        _ =
            Debug.log
                ("[Test Passed] "
                    ++ Debug.toString (testsDone model + 1)
                    ++ "/"
                    ++ Debug.toString numberOfTests
                )
                id
    in
    { model | passed = model.passed + 1 }
        |> end


failed : String -> String -> Model -> ( Model, Cmd Msg )
failed id error model =
    let
        _ =
            Debug.log "[Test Failed]" (id ++ ": " ++ error)
    in
    { model | failed = model.failed + 1 }
        |> end


end : Model -> ( Model, Cmd Msg )
end model =
    let
        _ =
            if testsDone model == numberOfTests then
                Debug.log "[End Test]"
                    ("passed: "
                        ++ Debug.toString model.passed
                        ++ ", failed: "
                        ++ Debug.toString model.failed
                    )

            else
                ""
    in
    ( model, Cmd.none )



-- View


view : Model -> Document Msg
view model =
    { title = "Browser Test - graphql-to-elm"
    , body = [ Html.text "GraphQL Integration Tests (see console)" ]
    }



-- Main


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
