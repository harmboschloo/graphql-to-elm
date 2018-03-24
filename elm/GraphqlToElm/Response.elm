module GraphqlToElm.Response
    exposing
        ( Response(Data, Errors)
        , mapData
        , mapErrors
        , decoder
        )

import Json.Decode as Decode exposing (Decoder)
import GraphqlToElm.Operation as Operation exposing (Operation)
import GraphqlToElm.Optional as Optional exposing (Optional(..))
import GraphqlToElm.Optional.Decode as OptionalDecode


type Response e a
    = Data a
    | Errors e (Optional a)


mapData : (a -> b) -> Response e a -> Response e b
mapData mapper response =
    case response of
        Data data ->
            Data (mapper data)

        Errors errors data ->
            Errors errors <|
                case data of
                    Absent ->
                        Absent

                    Null ->
                        Null

                    Present data ->
                        Present (mapper data)


mapErrors : (e1 -> e2) -> Response e1 a -> Response e2 a
mapErrors mapper response =
    case response of
        Data data ->
            Data data

        Errors errors data ->
            Errors (mapper errors) data


decoder : Operation t e a -> Decoder (Response e a)
decoder operation =
    Decode.oneOf
        [ Decode.map2 Errors
            (Decode.field "errors" <| Operation.errorsDecoder operation)
            (OptionalDecode.field "data" <| Operation.dataDecoder operation)
        , Decode.map Data
            (Decode.field "data" <| Operation.dataDecoder operation)
        ]
