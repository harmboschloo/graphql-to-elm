module Main exposing (main)

import Generated.Tests exposing (Test, tests)
import Html exposing (Html)
import GraphqlToElm exposing (Response(..), send, post)


numberOfTests : Int
numberOfTests =
    List.length tests



-- Model


type alias Model =
    { passed : Int
    , failed : Int
    }


init : ( Model, Cmd Msg )
init =
    let
        _ =
            Debug.log "[Start Test]"
                ("number of tests: " ++ toString numberOfTests)
    in
        ( Model 0 0
        , Cmd.batch (List.map sendTest tests)
        )


sendTest : Test -> Cmd Msg
sendTest test =
    send (TestResponseReceived test.id) <|
        post ("/graphql/" ++ test.id)
            { query = test.query
            , variables = test.variables
            }
            test.decoder



-- Update


type Msg
    = TestResponseReceived String (Response String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TestResponseReceived id (Data data) ->
            passed id data model

        TestResponseReceived id (Errors errors data) ->
            failed id
                ("Errors: " ++ toString { errors = errors, data = data })
                model

        TestResponseReceived id (HttpError error) ->
            failed id ("HttpError: " ++ toString error) model


passed : String -> String -> Model -> ( Model, Cmd Msg )
passed id data model =
    let
        _ =
            Debug.log "[Test Passed]" { id = id, data = data }
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
            if model.passed + model.failed == numberOfTests then
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
