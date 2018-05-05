module Main exposing (main)

import Html exposing (Html, div, h1, ul, li, hr, form, input, button, text)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onSubmit, onInput)
import GraphQL exposing (Response, send, getQuery, postMutation)
import Queries.Messages as Messages


-- Model


type Model
    = Loading
    | LoadError String
    | UserInput
        { messages : List Messages.Message
        , messageInput : String
        , error : Maybe String
        }
    | PostingMessage
        { messages : List Messages.Message
        , messageInput : String
        }


init : ( Model, Cmd Msg )
init =
    ( Loading
    , send MessagesResponded (getQuery Messages.messages)
    )



-- Update


type Msg
    = MessagesResponded (Result String Messages.MessagesQuery)
    | MessageChanged String
    | PostMessageRequested
    | PostMessageResponded (Result String Messages.PostMessageMutation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessagesResponded result ->
            case result of
                Err error ->
                    ( LoadError error, Cmd.none )

                Ok data ->
                    ( UserInput
                        { messages = data.messages
                        , messageInput = ""
                        , error = Nothing
                        }
                    , Cmd.none
                    )

        MessageChanged value ->
            case model of
                UserInput data ->
                    ( UserInput { data | messageInput = value }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        PostMessageRequested ->
            case model of
                UserInput { messages, messageInput } ->
                    ( PostingMessage
                        { messages = messages
                        , messageInput = messageInput
                        }
                    , send PostMessageResponded
                        (postMutation
                            (Messages.postMessage { message = messageInput })
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        PostMessageResponded result ->
            case model of
                PostingMessage { messages, messageInput } ->
                    case result of
                        Err error ->
                            ( UserInput
                                { messages = messages
                                , messageInput = messageInput
                                , error = Just error
                                }
                            , Cmd.none
                            )

                        Ok response ->
                            case response.postMessage of
                                Messages.OnMutationError { error } ->
                                    ( UserInput
                                        { messages = messages
                                        , messageInput = messageInput
                                        , error = Just error
                                        }
                                    , Cmd.none
                                    )

                                Messages.OnMessage message ->
                                    ( UserInput
                                        { messages = messages ++ [ message ]
                                        , messageInput = ""
                                        , error = Nothing
                                        }
                                    , Cmd.none
                                    )

                _ ->
                    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "graphql-to-elm basic example 2" ]
        , case model of
            Loading ->
                text "..."

            LoadError error ->
                text ("Error: " ++ error)

            UserInput data ->
                div []
                    [ viewMessages data.messages
                    , hr [] []
                    , viewPostError data.error
                    , viewPostInput data.messageInput
                    ]

            PostingMessage data ->
                div []
                    [ viewMessages data.messages
                    , hr [] []
                    , viewPostInput data.messageInput
                    ]
        ]


viewMessages : List Messages.Message -> Html Msg
viewMessages messages =
    case messages of
        [] ->
            div [] [ text "-- no messages --" ]

        _ ->
            ul [] (List.map viewMessage messages)


viewMessage : Messages.Message -> Html Msg
viewMessage { id, message } =
    li [] [ text ("(" ++ toString id ++ ") "), text message ]


viewPostError : Maybe String -> Html Msg
viewPostError error =
    case error of
        Nothing ->
            text ""

        Just error ->
            div [] [ text ("Error: " ++ error) ]


viewPostInput : String -> Html Msg
viewPostInput message =
    form [ onSubmit PostMessageRequested ]
        [ input [ value message, onInput MessageChanged ] []
        , button [ type_ "submit" ] [ text "post message" ]
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
