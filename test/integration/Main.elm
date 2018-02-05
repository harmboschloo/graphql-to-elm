module Main exposing (main)

import Generated.Tests
import Html exposing (Html)
import Http
import Json.Decode


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
                ("requests: " ++ toString (List.length requests))
    in
    ( Model 0 0, Cmd.batch requests )


requests : List (Cmd Msg)
requests =
    Generated.Tests.requests
        |> List.map
            (\{ id, body } ->
                Http.send (ResponseReceived id) <|
                    Http.post ("/graphql/" ++ id)
                        (Http.jsonBody body)
                        responseDecoder
            )


type alias Response =
    { data : Maybe Json.Decode.Value
    , errors : Maybe Json.Decode.Value
    }


responseDecoder : Json.Decode.Decoder Response
responseDecoder =
    Json.Decode.map2 Response
        (Json.Decode.maybe <| Json.Decode.field "data" Json.Decode.value)
        (Json.Decode.maybe <| Json.Decode.field "errors" Json.Decode.value)



-- Update


type Msg
    = ResponseReceived String (Result Http.Error Response)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived id (Ok response) ->
            case ( response.data, response.errors ) of
                ( Just _, Nothing ) ->
                    passed id model

                ( Just _, Just errors ) ->
                    failed id ("data with errors:" ++ toString errors) model

                ( Nothing, Just errors ) ->
                    failed id ("errors: " ++ toString errors) model

                ( Nothing, Nothing ) ->
                    failed id "empty response" model

        ResponseReceived id (Err error) ->
            failed id ("http error: " ++ toString error) model


passed : String -> Model -> ( Model, Cmd Msg )
passed id model =
    let
        _ =
            Debug.log "[Test Passed]" id
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
            if model.passed + model.failed == List.length requests then
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
    Html.text ""



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
