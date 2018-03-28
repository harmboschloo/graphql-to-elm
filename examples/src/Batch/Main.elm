module Batch.Main exposing (main)

import Regex
import Json.Encode as Encode
import Html exposing (Html, div, h2, pre, text)
import Batch.Queries as Queries exposing (UserQuery, MessagesQuery)
import GraphqlToElm.Batch as Batch exposing (Batch, Error)
import GraphqlToElm.Errors exposing (Errors)


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
    , Batch.send ResponseReceived <|
        Batch.post "/graphql" query
    )


query : Batch Errors Data
query =
    Batch.batch Data
        |> Batch.query Queries.user
        |> Batch.query Queries.messages


type Msg
    = ResponseReceived Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResponseReceived response ->
            ( Just response, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Query" ]
        , pre [] [ text (Batch.encode query |> Encode.encode 4) ]
        , h2 [] [ text "Response" ]
        , case model of
            Nothing ->
                text ""

            Just (Err error) ->
                text ("Http error: " ++ toString error)

            Just (Ok (Err errors)) ->
                text ("GraphQL errors: " ++ toString errors)

            Just (Ok (Ok data)) ->
                pre [] [ text (format data) ]
        ]


format : a -> String
format a =
    a
        |> toString
        |> Regex.replace Regex.All
            (Regex.regex "[,{}\\[\\]]")
            (\{ match } -> match ++ "\n")


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
