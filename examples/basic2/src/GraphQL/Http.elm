module GraphQL.Http exposing
    ( get
    , post
    )

import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation, Query)
import GraphQL.Response exposing (Response)
import Http
import Url.Builder


get : Operation Query Errors a -> (Result String a -> msg) -> Cmd msg
get operation msg =
    Http.get
        { url = Url.Builder.absolute [ "graphql" ] (GraphQL.Operation.queryParameters operation)
        , expect = Http.expectJson (mapResult >> msg) (GraphQL.Response.decoder operation)
        }


post : Operation t Errors a -> (Result String a -> msg) -> Cmd msg
post operation msg =
    Http.post
        { url = "/graphql"
        , body = Http.jsonBody (GraphQL.Operation.encode operation)
        , expect = Http.expectJson (mapResult >> msg) (GraphQL.Response.decoder operation)
        }


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

                Http.BadStatus status ->
                    Err ("Http bad status: " ++ String.fromInt status)

                Http.BadBody body ->
                    Err ("Http bad body: : " ++ body)

        Ok response ->
            case response of
                GraphQL.Response.Data data ->
                    Ok data

                GraphQL.Response.Errors [] _ ->
                    Err "GraphQL something went wrong"

                GraphQL.Response.Errors (first :: _) _ ->
                    Err first.message
