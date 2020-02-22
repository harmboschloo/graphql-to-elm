module Main exposing (main)

import Browser exposing (Document)
import GraphQL.Http
import Html exposing (Html, button, div, form, h1, hr, input, li, text, ul)
import Html.Attributes exposing (type_, value)
import Html.Events exposing (onInput, onSubmit)
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


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , GraphQL.Http.send MessagesResponded (GraphQL.Http.getQuery Messages.messages)
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
                    , GraphQL.Http.send PostMessageResponded
                        (GraphQL.Http.postMutation
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


view : Model -> Document Msg
view model =
    { title = "basic example 2 - graphql-to-elm"
    , body =
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
    }


viewMessages : List Messages.Message -> Html Msg
viewMessages messages =
    case messages of
        [] ->
            div [] [ text "-- no messages --" ]

        _ ->
            ul [] (List.map viewMessage messages)


viewMessage : Messages.Message -> Html Msg
viewMessage { id, message } =
    li [] [ text ("(" ++ String.fromInt id ++ ") "), text message ]


viewPostError : Maybe String -> Html Msg
viewPostError maybeError =
    case maybeError of
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


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
