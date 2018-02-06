module GraphqlToElm
    exposing
        ( Query
        , Request
        , Response(Data, Errors, HttpError)
        , Error
        , Location
        , post
        , send
        )

import Http
import Json.Decode exposing (Decoder)
import Json.Encode


type alias Query =
    { query : String
    , variables : Json.Encode.Value
    }


encodeQuery : Query -> Json.Encode.Value
encodeQuery { query, variables } =
    Json.Encode.object
        [ ( "query", Json.Encode.string query )
        , ( "variables", variables )
        ]


type Request a
    = Request (Http.Request (Response a))


type Response a
    = Data a
    | Errors (List Error) (Maybe a)
    | HttpError Http.Error


type alias Error =
    { message : String
    , locations : List Location
    }


type alias Location =
    { line : Int
    , column : Int
    }


responseDecoder : Decoder a -> Decoder (Response a)
responseDecoder dataDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map2 Errors
            (Json.Decode.field "errors" <| Json.Decode.list errorDecoder)
            (Json.Decode.maybe <| Json.Decode.field "data" dataDecoder)
        , Json.Decode.map Data <| Json.Decode.field "data" dataDecoder
        ]


errorDecoder : Decoder Error
errorDecoder =
    Json.Decode.map2 Error
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "locations" <|
            Json.Decode.list <|
                Json.Decode.map2 Location
                    (Json.Decode.field "line" Json.Decode.int)
                    (Json.Decode.field "columnline" Json.Decode.int)
        )


post : String -> Query -> Decoder a -> Request a
post url query dataDecoder =
    Request <|
        Http.post
            url
            (Http.jsonBody <| encodeQuery query)
            (responseDecoder dataDecoder)


send : (Response a -> msg) -> Request a -> Cmd msg
send responseMsg (Request request) =
    Http.send (toResponse >> responseMsg) request


toResponse : Result Http.Error (Response a) -> Response a
toResponse result =
    case result of
        Err error ->
            HttpError error

        Ok response ->
            response
