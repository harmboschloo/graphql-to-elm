module Fragments.Main exposing (main)

import Http
import Html exposing (Html, div, ul, li, dl, dt, dd, text)
import Fragments.Queries as Queries
    exposing
        ( UserResponse
        , MessagesResponse
        , UserQuery
        , MessagesQuery
        , User
        , Message
        )
import GraphqlToElm.Operation as Operation
import GraphqlToElm.Http exposing (postQuery)
import Helpers exposing (endpoint, viewQueryAndResponse)


-- Model


type alias Model =
    { user : Maybe (Result Http.Error UserResponse)
    , messages : Maybe (Result Http.Error MessagesResponse)
    }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing
    , Cmd.batch
        [ Http.send UserResponseReceived (postQuery endpoint Queries.user)
        , Http.send MessagesResponseReceived (postQuery endpoint Queries.messages)
        ]
    )



-- Update


type Msg
    = UserResponseReceived (Result Http.Error UserResponse)
    | MessagesResponseReceived (Result Http.Error MessagesResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserResponseReceived result ->
            ( { model | user = Just result }, Cmd.none )

        MessagesResponseReceived result ->
            ( { model | messages = Just result }, Cmd.none )



-- View


view : Model -> Html msg
view model =
    div []
        [ viewQueryAndResponse
            "User"
            viewUserData
            (Operation.encode Queries.user)
            model.user
        , viewQueryAndResponse
            "Messages"
            viewMessagesData
            (Operation.encode Queries.messages)
            model.messages
        ]


viewUserData : UserQuery -> Html msg
viewUserData data =
    viewUser data.user


viewMessagesData : MessagesQuery -> Html msg
viewMessagesData data =
    dl []
        [ dt [] [ text "Last Message" ]
        , dd []
            [ data.lastMessage
                |> Maybe.map viewMessage
                |> Maybe.withDefault (text "Nothing")
            ]
        , dt [] [ text "Messages" ]
        , dd []
            [ ul []
                (List.map
                    (\message -> li [] [ viewMessage message ])
                    data.messages
                )
            ]
        ]


viewUser : User -> Html msg
viewUser user =
    dl []
        [ dt [] [ text "User" ]
        , dd []
            [ dl []
                [ dt [] [ text "id" ]
                , dd [] [ text user.id ]
                , dt [] [ text "name" ]
                , dd [] [ text user.name ]
                , dt [] [ text "email" ]
                , dd [] [ text user.email ]
                ]
            ]
        ]


viewMessage : Message -> Html msg
viewMessage message =
    dl []
        [ dt [] [ text "Message" ]
        , dd []
            [ dl []
                [ dt [] [ text "id" ]
                , dd [] [ text message.id ]
                , dt [] [ text "message" ]
                , dd [] [ text message.message ]
                , dt [] [ text "from" ]
                , dd [] [ viewUser message.from ]
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
