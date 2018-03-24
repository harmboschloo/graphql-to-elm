module Main exposing (main)

import Set
import Tests exposing (Test, tests)
import Html exposing (Html)
import Http as RegularHttp
import GraphqlToElm.Response as GraphqlResponse
import GraphqlToElm.Http as Http exposing (Response, Error(..))
import GraphqlToElm.Batch as Batch exposing (Batch)


numberOfRounds : Int
numberOfRounds =
    100


postTests : List Test
postTests =
    tests
        |> List.repeat numberOfRounds
        |> List.concat


schemaIds : List String
schemaIds =
    tests
        |> List.map .schemaId
        |> Set.fromList
        |> Set.toList


testsBySchema : List ( String, List Test )
testsBySchema =
    schemaIds
        |> List.map
            (\schemaId ->
                ( schemaId
                , List.filter (\test -> test.schemaId == schemaId) tests
                )
            )


type alias BatchData =
    List (GraphqlResponse.Response String String)


batch2Tests : List ( String, String, Batch BatchData )
batch2Tests =
    testsBySchema
        |> List.map
            (\( schemaId, tests ) ->
                List.map2
                    (\a b ->
                        ( schemaId
                        , "[" ++ a.id ++ "," ++ b.id ++ "]"
                        , Batch.batch2
                            (\a b ->
                                [ a
                                    |> GraphqlResponse.mapData toString
                                    |> GraphqlResponse.mapErrors toString
                                , b
                                    |> GraphqlResponse.mapData toString
                                    |> GraphqlResponse.mapErrors toString
                                ]
                            )
                            a.operation
                            b.operation
                        )
                    )
                    (tests)
                    (List.reverse tests)
            )
        |> List.concat


getTests : List Test
getTests =
    tests
        |> List.filter (\test -> not <| List.member test.id getTestBlackList)
        |> List.repeat numberOfRounds
        |> List.concat


getTestBlackList : List String
getTestBlackList =
    [ "operations-named-Tests.OperationsNamed.Query-mutation"
    , "operations-Tests.Operations.MultipleFragments-mutation"
    , "operations-Tests.Operations.Multiple-mutation"
    , "operations-Tests.Operations.AnonymousMutation-mutation"
    ]


numberOfTests : Int
numberOfTests =
    List.length postTests
        + List.length batch2Tests
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
        , [ List.map sendPost postTests
          , List.map sendBatch batch2Tests
          , List.map sendGet getTests
          ]
            |> List.concat
            |> Cmd.batch
        )


sendPost : Test -> Cmd Msg
sendPost test =
    Http.send (TestResponseReceived test.id) <|
        Http.post ("/graphql/" ++ test.schemaId) test.operation


sendBatch : ( String, String, Batch BatchData ) -> Cmd Msg
sendBatch ( schemaId, id, batch ) =
    Batch.send (TestBatchResponseReceived id) <|
        Batch.post ("/graphql/" ++ schemaId) batch


sendGet : Test -> Cmd Msg
sendGet test =
    Http.send (TestResponseReceived test.id) <|
        Http.get ("/graphql/" ++ test.schemaId) test.operation



-- Update


type Msg
    = TestResponseReceived String (Response String String)
    | TestBatchResponseReceived String (Result RegularHttp.Error BatchData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TestResponseReceived id (Ok data) ->
            passed id data model

        TestResponseReceived id (Err (GraphqlError errors data)) ->
            failed id
                ("Errors: " ++ toString { errors = errors, data = data })
                model

        TestResponseReceived id (Err (HttpError error)) ->
            failed id ("HttpError: " ++ toString error) model

        TestBatchResponseReceived id (Ok data) ->
            data
                |> List.filterMap
                    (\response ->
                        case response of
                            GraphqlResponse.Errors errors _ ->
                                Just errors

                            GraphqlResponse.Data _ ->
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
