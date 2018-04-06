module Variables.Main exposing (main)

import Http
import Html exposing (Html, dl, dt, dd, text)
import Language exposing (Language)
import Variables.Query
    exposing
        ( GetTranslationResponse
        , GetTranslationQuery
        , getTranslation
        )
import GraphqlToElm.Errors exposing (Errors)
import GraphqlToElm.Operation as Operation exposing (Operation, Query)
import GraphqlToElm.Optional as Optional
import GraphqlToElm.Http exposing (postQuery)
import Helpers exposing (endpoint, viewQueryAndResponse)


-- Model


type alias Model =
    { id : String
    , language : Language
    , translation : Maybe (Result Http.Error GetTranslationResponse)
    }


init : ( Model, Cmd Msg )
init =
    let
        model =
            Model "hello.world" Language.En Nothing

        cmd =
            Http.send ResponseReceived <|
                postQuery endpoint (operation model)
    in
        ( model, cmd )


operation : Model -> Operation Query Errors GetTranslationQuery
operation model =
    getTranslation
        { id = model.id
        , language = Optional.Present model.language
        }



-- Update


type Msg
    = ResponseReceived (Result Http.Error GetTranslationResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived result ->
            ( { model | translation = Just result }, Cmd.none )



-- View


view : Model -> Html msg
view model =
    viewQueryAndResponse
        "Translation"
        viewData
        (Operation.encode <| operation model)
        model.translation


viewData : GetTranslationQuery -> Html msg
viewData data =
    dl []
        [ dt [] [ text "Translation" ]
        , dd []
            [ data.translation
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
