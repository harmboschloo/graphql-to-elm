module Fields.Main exposing (main)

import Html exposing (Html, div, h3, ul, li, dl, dt, dd, text)
import Fields.Queries as Queries
    exposing
        ( BasicQuery
        , MaybeQuery
        , ListQuery
        , User
        , Message
        )
import GraphqlToElm.Operation as Operation
import GraphqlToElm.Response as Response exposing (Response)
import GraphqlToElm.Errors exposing (Errors)
import GraphqlToElm.Http as Http
import Helpers exposing (endpoint, viewQueryAndResponse)


-- Model


type alias Model =
    { basic : Maybe (Result Http.Error BasicResponse)
    , maybe : Maybe (Result Http.Error MaybeResponse)
    , list : Maybe (Result Http.Error ListResponse)
    }


type alias BasicResponse =
    Response Errors Queries.BasicQuery


type alias MaybeResponse =
    Response Errors Queries.MaybeQuery


type alias ListResponse =
    Response Errors Queries.ListQuery


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing Nothing
    , Cmd.batch
        [ Http.send BasicResponseReceived
            (Http.postQuery endpoint Queries.basic)
        , Http.send MaybeResponseReceived
            (Http.postQuery endpoint Queries.maybe)
        , Http.send ListResponseReceived
            (Http.postQuery endpoint Queries.list)
        ]
    )



-- Update


type Msg
    = BasicResponseReceived (Result Http.Error BasicResponse)
    | MaybeResponseReceived (Result Http.Error MaybeResponse)
    | ListResponseReceived (Result Http.Error ListResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BasicResponseReceived result ->
            ( { model | basic = Just result }, Cmd.none )

        MaybeResponseReceived result ->
            ( { model | maybe = Just result }, Cmd.none )

        ListResponseReceived result ->
            ( { model | list = Just result }, Cmd.none )



-- View


view : Model -> Html msg
view model =
    div []
        [ viewQueryAndResponse
            "Basic"
            viewBasic
            (Operation.encode Queries.basic)
            model.basic
        , viewQueryAndResponse
            "Maybe"
            viewMaybe
            (Operation.encode Queries.maybe)
            model.maybe
        , viewQueryAndResponse
            "List"
            viewList
            (Operation.encode Queries.list)
            model.list
        ]


viewBasic : BasicQuery -> Html msg
viewBasic data =
    viewUser data.user


viewMaybe : MaybeQuery -> Html msg
viewMaybe data =
    case data.lastMessage of
        Nothing ->
            text "Nothing"

        Just message ->
            viewMessage message


viewList : ListQuery -> Html msg
viewList data =
    viewMessages data.messages


viewUser : User -> Html msg
viewUser user =
    dl []
        [ dt [] [ text "User" ]
        , dd []
            [ dl []
                [ dt [] [ text "name" ]
                , dd [] [ text user.name ]
                , dt [] [ text "email" ]
                , dd [] [ text user.email ]
                ]
            ]
        ]


viewMessages : List Message -> Html msg
viewMessages messages =
    dl []
        [ dt [] [ text "Messages" ]
        , dd []
            [ ul []
                (List.map
                    (\message -> li [] [ viewMessage message ])
                    messages
                )
            ]
        ]


viewMessage : Message -> Html msg
viewMessage message =
    dl []
        [ dt [] [ text "Message" ]
        , dd []
            [ dl []
                [ dt [] [ text "message" ]
                , dd [] [ text message.message ]
                ]
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
