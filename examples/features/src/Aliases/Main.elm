module Aliases.Main exposing (main)

import Http
import Html exposing (Html, dl, dt, dd, text)
import Aliases.Query as Query exposing (Response, Query, query)
import GraphqlToElm.Operation as Operation
import GraphqlToElm.Http exposing (postQuery)
import Helpers exposing (endpoint, viewQueryAndResponse)


-- Model


type alias Model =
    Maybe (Result Http.Error Response)


init : ( Model, Cmd Msg )
init =
    ( Nothing
    , Http.send ResponseReceived (postQuery endpoint query)
    )



-- Update


type Msg
    = ResponseReceived (Result Http.Error Response)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived result ->
            ( Just result, Cmd.none )



-- View


view : Model -> Html msg
view model =
    viewQueryAndResponse
        "Aliases"
        viewData
        (Operation.encode query)
        model


viewData : Query -> Html msg
viewData data =
    dl []
        [ dt [] [ text "hello.world EN" ]
        , dd [] [ text (data.helloWorldEn |> Maybe.withDefault "Nothing") ]
        , dt [] [ text "hello.world NL" ]
        , dd [] [ text (data.helloWorldNl |> Maybe.withDefault "Nothing") ]
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
