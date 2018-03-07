module GraphqlToElm.Helpers.Url
    exposing
        ( withParameters
        , joinParameters
        )


withParameters : String -> List ( String, String ) ->  String
withParameters url parameters =
    url ++ "?" ++ joinParameters parameters


joinParameters : List ( String, String ) -> String
joinParameters parameters =
    parameters
        |> List.map (\( key, value ) -> key ++ "=" ++ value)
        |> String.join "&"
