module GraphQL.Http exposing
    ( getQuery
    , postMutation
    , send
    )

import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Mutation, Operation, Query)
import GraphQL.Response exposing (Response)
import Http
import Url.Builder


getQuery : Operation Query Errors a -> Http.Request (Response Errors a)
getQuery operation =
    Http.get
        (Url.Builder.absolute [ "graphql" ] (GraphQL.Operation.queryParameters operation))
        (GraphQL.Response.decoder operation)


postMutation : Operation Mutation Errors a -> Http.Request (Response Errors a)
postMutation operation =
    Http.post
        "/graphql"
        (Http.jsonBody <| GraphQL.Operation.encode operation)
        (GraphQL.Response.decoder operation)


send : (Result String a -> msg) -> Http.Request (Response Errors a) -> Cmd msg
send resultMsg =
    Http.send (mapResult >> resultMsg)


mapResult : Result Http.Error (Response Errors a) -> Result String a
mapResult result =
    case result of
        Err error ->
            case error of
                Http.BadUrl url ->
                    Err ("Http bad url: " ++ url)

                Http.Timeout ->
                    Err "Http timeout"

                Http.NetworkError ->
                    Err "Http network error"

                Http.BadStatus response ->
                    Err ("Http bad status: " ++ response.status.message)

                Http.BadPayload message _ ->
                    Err ("Http bad payload: : " ++ message)

        Ok response ->
            case response of
                GraphQL.Response.Data data ->
                    Ok data

                GraphQL.Response.Errors [] _ ->
                    Err "GraphQL something went wrong"

                GraphQL.Response.Errors (first :: _) _ ->
                    Err first.message
