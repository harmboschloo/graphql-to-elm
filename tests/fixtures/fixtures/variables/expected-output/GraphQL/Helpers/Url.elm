module GraphQL.Helpers.Url
    exposing
        ( withParameters
        , joinParameters
        )

{-| Some functions that help dealing with urls.

@docs withParameters, joinParameters

-}


{-| Add parameters to an url.

    withParameters "url.com" [ ( "a", "1" ), ( "b", "2" ) ] == "url.com?a=1&b=2"

-}
withParameters : String -> List ( String, String ) -> String
withParameters url parameters =
    url ++ "?" ++ joinParameters parameters


{-| Join url parameters.

    joinParameters [ ( "a", "1" ), ( "b", "2" ) ] == "a=1&b=2"

-}
joinParameters : List ( String, String ) -> String
joinParameters parameters =
    parameters
        |> List.map (\( key, value ) -> key ++ "=" ++ value)
        |> String.join "&"
