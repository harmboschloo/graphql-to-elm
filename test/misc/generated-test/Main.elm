module Main exposing (main)

import Html exposing (Html)


-- Model


type alias Model =
    ()


init : ( Model, Cmd msg )
init =
    ( Debug.log "Hello Init" (), Cmd.none )



-- Update


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    let
        _ =
            Debug.crash "HELLO CRASH"
    in
    Html.text "Hello"



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }
