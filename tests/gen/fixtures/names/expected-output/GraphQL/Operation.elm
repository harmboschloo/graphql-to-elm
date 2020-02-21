module GraphQL.Operation exposing
    ( Operation, Query, Mutation, Subscription
    , withName, withQuery
    , encode
    , queryParameters
    , dataDecoder, errorsDecoder
    , mapData, mapErrors
    )

{-| A GraphQL operation.

@docs Operation, Query, Mutation, Subscription

@docs withName, withQuery

@docs encode

@docs queryParameters

@docs dataDecoder, errorsDecoder

@docs mapData, mapErrors

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Url.Builder as UrlBuilder exposing (QueryParameter)


{-| -}
type Operation t e a
    = Operation
        { kind : Kind
        , maybeVariables : Maybe Encode.Value
        , dataDecoder : Decoder a
        , errorsDecoder : Decoder e
        }


{-| -}
type Query
    = Query


{-| -}
type Mutation
    = Mutation


{-| -}
type Subscription
    = Subscription


type Kind
    = WithName String
    | WithQuery String


{-| -}
withName :
    String
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation t e a
withName name =
    initOperation (WithName name)


{-| -}
withQuery :
    String
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation t e a
withQuery query =
    initOperation (WithQuery query)


initOperation :
    Kind
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation t e a
initOperation kind maybeVariables operationDataDecoder operationErrorsDecoder =
    Operation
        { kind = kind
        , maybeVariables = maybeVariables
        , dataDecoder = operationDataDecoder
        , errorsDecoder = operationErrorsDecoder
        }


{-| -}
dataDecoder : Operation t e a -> Decoder a
dataDecoder (Operation operation) =
    operation.dataDecoder


{-| -}
mapData : (a -> b) -> Operation t e a -> Operation t e b
mapData mapper (Operation operation) =
    Operation
        { kind = operation.kind
        , maybeVariables = operation.maybeVariables
        , dataDecoder = Decode.map mapper operation.dataDecoder
        , errorsDecoder = operation.errorsDecoder
        }


{-| -}
errorsDecoder : Operation t e a -> Decoder e
errorsDecoder (Operation operation) =
    operation.errorsDecoder


{-| -}
mapErrors : (e1 -> e2) -> Operation t e1 a -> Operation t e2 a
mapErrors mapper (Operation operation) =
    Operation
        { kind = operation.kind
        , maybeVariables = operation.maybeVariables
        , dataDecoder = operation.dataDecoder
        , errorsDecoder = Decode.map mapper operation.errorsDecoder
        }


{-| -}
encode : Operation t e a -> Encode.Value
encode (Operation operation) =
    let
        queryField =
            case operation.kind of
                WithName name ->
                    ( "operationName", Encode.string name )

                WithQuery query ->
                    ( "query", Encode.string query )

        otherFields =
            case operation.maybeVariables of
                Nothing ->
                    []

                Just variables ->
                    [ ( "variables", variables ) ]
    in
    Encode.object (queryField :: otherFields)


{-| -}
queryParameters : Operation t e a -> List QueryParameter
queryParameters (Operation { kind, maybeVariables }) =
    let
        operationParameter =
            case kind of
                WithName name ->
                    UrlBuilder.string "operationName" name

                WithQuery query ->
                    UrlBuilder.string "query" query

        otherParameters =
            case maybeVariables of
                Nothing ->
                    []

                Just variables ->
                    [ UrlBuilder.string "variables" (Encode.encode 0 variables) ]
    in
    operationParameter :: otherParameters
