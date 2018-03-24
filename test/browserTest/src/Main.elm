module Main exposing (main)

import Set
import Tests exposing (Test, queryTests, mutationTests)
import Html exposing (Html)
import GraphqlToElm.Operation exposing (Query, Mutation)
import GraphqlToElm.Response as Response exposing (Response(Data, Errors))
import GraphqlToElm.Http as Http
import GraphqlToElm.Batch as Batch exposing (Batch)


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


type alias BatchData =
    List (Response String String)


batchTests : List ( String, String, Batch BatchData )
batchTests =
    let
        id2 a b =
            "[" ++ String.join "," [ a.id, b.id ] ++ "]"

        id3 a b c =
            "[" ++ String.join "," [ a.id, b.id, c.id ] ++ "]"

        map =
            Response.mapData toString >> Response.mapErrors toString

        map2 a b =
            [ map a, map b ]

        map3 a b c =
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
                                , Batch.query map2 a.operation
                                    |> Batch.andQuery b.operation
                                )
                            )
                            (queryTests)
                            (List.reverse queryTests)
                        , List.map3
                            (\a b c ->
                                ( schemaId
                                , id3 a b c
                                , Batch.query map3 a.operation
                                    |> Batch.andMutation b.operation
                                    |> Batch.andQuery c.operation
                                )
                            )
                            (queryTests)
                            (mutationTests)
                            (List.reverse queryTests)
                        , List.map2
                            (\a b ->
                                ( schemaId
                                , id2 a b
                                , Batch.mutation map2 a.operation
                                    |> Batch.andMutation b.operation
                                )
                            )
                            (List.reverse mutationTests)
                            (mutationTests)
                        ]
                )
            |> List.concat


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
        + List.length getTests



-- Model


type alias Model =
    { passed : Int
    , failed : Int
    }


testsDone : Model -> Int
testsDone { passed, failed } =
    passed + failed


init : ( Model, Cmd Msg )
init =
    let
        _ =
            Debug.log "[Start Test] number of tests" numberOfTests
    in
        ( Model 0 0
        , [ List.map sendPostQuery postQueryTests
          , List.map sendPostMutation postMutationTests
          , List.map sendBatch batchTests
          , List.map sendGet getTests
          ]
            |> List.concat
            |> Cmd.batch
        )


sendPostQuery : Test Query -> Cmd Msg
sendPostQuery test =
    Http.send (TestResponseReceived test.id) <|
        Http.postQuery ("/graphql/" ++ test.schemaId) test.operation


sendPostMutation : Test Mutation -> Cmd Msg
sendPostMutation test =
    Http.send (TestResponseReceived test.id) <|
        Http.postMutation ("/graphql/" ++ test.schemaId) test.operation


sendBatch : ( String, String, Batch BatchData ) -> Cmd Msg
sendBatch ( schemaId, id, batch ) =
    Batch.send (TestBatchResponseReceived id) <|
        Batch.post ("/graphql/" ++ schemaId) batch


sendGet : Test Query -> Cmd Msg
sendGet test =
    Http.send (TestResponseReceived test.id) <|
        Http.getQuery ("/graphql/" ++ test.schemaId) test.operation



-- Update


type Msg
    = TestResponseReceived String (Result Http.Error (Response String String))
    | TestBatchResponseReceived String (Result Batch.Error BatchData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TestResponseReceived id (Ok (Data data)) ->
            passed id data model

        TestResponseReceived id (Ok (Errors errors data)) ->
            failed id
                ("Errors: " ++ toString { errors = errors, data = data })
                model

        TestResponseReceived id (Err error) ->
            failed id ("HttpError: " ++ toString error) model

        TestBatchResponseReceived id (Ok data) ->
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
                |> Maybe.withDefault (passed id (toString data) model)

        TestBatchResponseReceived id (Err error) ->
            failed id ("HttpError: " ++ toString error) model


passed : String -> String -> Model -> ( Model, Cmd Msg )
passed id data model =
    let
        _ =
            Debug.log
                ("[Test Passed] "
                    ++ toString (testsDone model + 1)
                    ++ "/"
                    ++ (toString numberOfTests)
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
                        ++ toString model.passed
                        ++ ", failed: "
                        ++ toString model.failed
                    )
            else
                ""
    in
        ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    Html.text "GraphqlToElm Integration Tests (see console)"



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
