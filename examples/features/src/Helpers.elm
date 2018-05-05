module Helpers exposing (endpoint, viewQueryAndResponse, viewQueryAndResult)

import Json.Encode as Encode
import Http
import Html exposing (Html, div, h1, h2, hr ,ul, li, span, pre, text)
import GraphqlToElm.Errors exposing (Errors, Error, Location)
import GraphqlToElm.Response as Response exposing (Response)


endpoint : String
endpoint =
    "/graphql"


viewQueryAndResponse :
    String
    -> (a -> Html msg)
    -> Encode.Value
    -> Maybe (Result Http.Error (Response Errors a))
    -> Html msg
viewQueryAndResponse name viewData query response =
    div []
        [ h1 [] [ text name, text " Query" ]
        , pre [] [ text (Encode.encode 4 query) ]
        , h1 [] [ text name, text " Response" ]
        , case response of
            Nothing ->
                h2 [] [ text "..." ]

            Just (Err error) ->
                div []
                    [ h2 [] [ text "Http Error" ]
                    , viewHttpError error
                    ]

            Just (Ok (Response.Errors errors _)) ->
                div []
                    [ h2 [] [ text "GraphQL Errors" ]
                    , viewErrors errors
                    ]

            Just (Ok (Response.Data data)) ->
                div []
                    [ h2 [] [ text "Ok" ]
                    , viewData data
                    ]
        , hr [] []
        ]


viewQueryAndResult :
    (a -> Html msg)
    -> Encode.Value
    -> Maybe (Result Http.Error (Result Errors a))
    -> Html msg
viewQueryAndResult viewData query response =
    div []
        [ h1 [] [ text "Query" ]
        , pre [] [ text (Encode.encode 4 query) ]
        , h1 [] [ text "Response" ]
        , case response of
            Nothing ->
                h2 [] [ text "..." ]

            Just (Err error) ->
                div []
                    [ h2 [] [ text "Http Error" ]
                    , viewHttpError error
                    ]

            Just (Ok (Err errors)) ->
                div []
                    [ h2 [] [ text "GraphQL Errors" ]
                    , viewErrors errors
                    ]

            Just (Ok (Ok data)) ->
                div []
                    [ h2 [] [ text "Ok" ]
                    , viewData data
                    ]
        ]


viewHttpError : Http.Error -> Html msg
viewHttpError error =
    case error of
        Http.BadUrl message ->
            span [] [ text "BadUrl: ", text message ]

        Http.Timeout ->
            span [] [ text "Timeout" ]

        Http.NetworkError ->
            span [] [ text "NetworkError" ]

        Http.BadStatus response ->
            span [] [ text "BadStatus: ", text response.status.message ]

        Http.BadPayload message _ ->
            span [] [ text "BadPayload: ", text message ]


viewErrors : Errors -> Html msg
viewErrors errors =
    ul [] (List.map viewError errors)


viewError : Error -> Html msg
viewError error =
    li []
        [ text error.message
        , error.locations
            |> Maybe.map (List.map viewLocation >> ul [])
            |> Maybe.withDefault (text "")
        ]


viewLocation : Location -> Html msg
viewLocation location =
    li []
        [ text "line "
        , text (toString location.line)
        , text ", column "
        , text (toString location.column)
        ]
