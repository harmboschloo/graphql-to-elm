module Batch.Main exposing (main)

import Html exposing (Html, div, h3, ul, li, dl, dt, dd, text)
import Batch.Queries as Queries
    exposing
        ( UserQuery
        , MessagesQuery
        , User
        , Message
        )
import GraphqlToElm.Batch as Batch exposing (Batch, Error)
import GraphqlToElm.Errors exposing (Errors)
import Helpers exposing (endpoint, viewQueryAndResult)


-- Model


type alias Model =
    Maybe Response


type alias Response =
    Result Batch.Error (Result Errors Data)


type alias Data =
    { userQuery : UserQuery
    , messagesQuery : MessagesQuery
    }


init : ( Model, Cmd Msg )
init =
    ( Nothing
    , Batch.send ResponseReceived (Batch.post endpoint query)
    )


query : Batch Errors Data
query =
    Batch.batch Data
        |> Batch.query Queries.user
        |> Batch.query Queries.messages



-- Update


type Msg
    = ResponseReceived Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived response ->
            ( Just response, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    viewQueryAndResult
        viewData
        (Batch.encode query)
        model


viewData : Data -> Html Msg
viewData data =
    div []
        [ h3 [] [ text "User query" ]
        , viewUser data.userQuery.user
        , h3 [] [ text "Messages query" ]
        , viewMessages data.messagesQuery.messages
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
