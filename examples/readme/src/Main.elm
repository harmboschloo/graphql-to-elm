module Main exposing (main)

import Browser exposing (Document)
import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation, Query)
import GraphQL.Response exposing (Response)
import Html
import Http
import MyQuery



-- Requests


postQuery : Operation Query Errors a -> Http.Request (Response Errors a)
postQuery operation =
    Http.post
        "/graphql"
        (Http.jsonBody (GraphQL.Operation.encode operation))
        (GraphQL.Response.decoder operation)



-- Model


init : () -> ( String, Cmd Msg )
init _ =
    ( "", Http.send GotUserName (postQuery MyQuery.userName) )



-- Update


type Msg
    = GotUserName (Result Http.Error (Response Errors MyQuery.UserNameQuery))


update : Msg -> String -> ( String, Cmd Msg )
update msg _ =
    case msg of
        GotUserName (Ok (GraphQL.Response.Data data)) ->
            ( "user name: " ++ data.user.name, Cmd.none )

        GotUserName (Ok (GraphQL.Response.Errors _ _)) ->
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
