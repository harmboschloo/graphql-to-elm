module Mutations.Main exposing (main)

import Http
import Html exposing (Html, dl, dt, dd, text)
import Mutations.Query
    exposing
        ( PostMessageResponse
        , PostMessageMutation
        , postMessage
        )
import GraphqlToElm.Operation as Operation
import GraphqlToElm.Http exposing (postMutation)
import Helpers exposing (endpoint, viewQueryAndResponse)


-- Model


type alias Model =
    { postMessage : Maybe (Result Http.Error PostMessageResponse)
    }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing
    , Http.send ResponseReceived <|
        postMutation endpoint <|
            postMessage { message = "Hello World" }
    )



-- Update


type Msg
    = ResponseReceived (Result Http.Error PostMessageResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived result ->
            ( { model | postMessage = Just result }, Cmd.none )



-- View


view : Model -> Html msg
view model =
    viewQueryAndResponse
        "PostMessageMutation"
        viewData
        (Operation.encode <| postMessage { message = "Hello World" })
        model.postMessage


viewData : PostMessageMutation -> Html msg
viewData data =
    dl []
        [ dt [] [ text "Message ID" ]
        , dd []
            [ data.postMessage
                |> Maybe.map text
                |> Maybe.withDefault (text "Nothing")
            ]
        ]



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
