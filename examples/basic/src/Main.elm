module Main exposing (main)

import Html exposing (Html, div, h1, ul, li, text)
import Http
import GraphQL exposing (Response, send, getQuery)
import GraphqlToElm.Optional as Optional exposing (Optional)
import GraphqlToElm.Response as Response
import Queries.Messages as Messages exposing (Message)


-- Model


type Model
    = Loading
    | HttpError Http.Error
    | GraphQLErrors (List String) (Optional (List Message))
    | Loaded (List Message)


init : ( Model, Cmd Msg )
init =
    ( Loading
    , send MessagesResponded (getQuery Messages.query)
    )



-- Update


type Msg
    = MessagesResponded (Result Http.Error (Response Messages.Query))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessagesResponded result ->
            case result of
                Err error ->
                    ( HttpError error, Cmd.none )

                Ok response ->
                    case response of
                        Response.Errors errors data ->
                            ( GraphQLErrors
                                (List.map .message errors)
                                (Optional.map .messages data)
                            , Cmd.none
                            )

                        Response.Data data ->
                            ( Loaded data.messages, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "graphql-to-elm basic example" ]
        , case model of
            Loading ->
                text "..."

            HttpError _ ->
                text ("Http error")

            GraphQLErrors errors data ->
                div []
                    [ div []
                        [ text "errors:"
                        , ul [] (List.map viewError errors)
                        ]
                    , div []
                        [ text "messages:"
                        , data
                            |> Optional.map viewMessages
                            |> Optional.withDefault (text "Nothing")
                        ]
                    ]

            Loaded messages ->
                div [] [ text "messages:", viewMessages messages ]
        ]


viewError : String -> Html msg
viewError error =
    li [] [ text error ]


viewMessages : List Message -> Html Msg
viewMessages messages =
    case messages of
        [] ->
            div [] [ text "-- no messages --" ]

        _ ->
            ul [] (List.map viewMessage messages)


viewMessage : Message -> Html Msg
viewMessage { message } =
    li [] [ text message ]



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
