module Main exposing (main)

import Browser exposing (Document)
import GraphQL.Errors exposing (Errors)
import GraphQL.Http.Basic exposing (postQuery)
import GraphQL.Response as Response exposing (Response)
import Html
import Http
import MyQuery



-- Model


init : () -> ( String, Cmd Msg )
init _ =
    ( "", Http.send GotUserName (postQuery "/graphql" MyQuery.userName) )



-- Update


type Msg
    = GotUserName (Result Http.Error (Response Errors MyQuery.UserNameQuery))


update : Msg -> String -> ( String, Cmd Msg )
update msg model =
    case msg of
        GotUserName (Ok (Response.Data data)) ->
            ( "user name: " ++ data.user.name, Cmd.none )

        GotUserName (Ok (Response.Errors _ _)) ->
            ( "GraphQL error", Cmd.none )

        GotUserName (Err _) ->
            ( "Http error", Cmd.none )



-- View


view : String -> Document Msg
view string =
    { title = "readme example - graphql-to-elm"
    , body =
        [ Html.text string ]
    }



-- Main


main : Program () String Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
