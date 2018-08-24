module GraphQL.Operation
    exposing
        ( Operation
        , Query
        , Mutation
        , Subscription
        , withName
        , withQuery
        , dataDecoder
        , mapData
        , errorsDecoder
        , mapErrors
        , encode
        , encodeParameters
        )

{-| A GraphQL operation.

@docs Operation, Query, Mutation, Subscription

@docs withName, withQuery

@docs encode, encodeParameters

@docs dataDecoder, errorsDecoder

@docs mapData, mapErrors

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Http exposing (encodeUri)


{-| -}
type Operation t e a
    = Operation
        { kind : Kind
        , variables : Maybe Encode.Value
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
    operation (WithName name)


{-| -}
withQuery :
    String
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation t e a
withQuery query =
    operation (WithQuery query)


operation :
    Kind
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation t e a
operation kind variables dataDecoder errorsDecoder =
    Operation
        { kind = kind
        , variables = variables
        , dataDecoder = dataDecoder
        , errorsDecoder = errorsDecoder
        }


{-| -}
dataDecoder : Operation t e a -> Decoder a
dataDecoder (Operation operation) =
    operation.dataDecoder


{-| -}
mapData : (a -> b) -> Operation t e a -> Operation t e b
mapData mapper (Operation operation) =
    Operation
        { operation | dataDecoder = Decode.map mapper operation.dataDecoder }


{-| -}
errorsDecoder : Operation t e a -> Decoder e
errorsDecoder (Operation operation) =
    operation.errorsDecoder


{-| -}
mapErrors : (e1 -> e2) -> Operation t e1 a -> Operation t e2 a
mapErrors mapper (Operation operation) =
    Operation
        { operation
            | errorsDecoder = Decode.map mapper operation.errorsDecoder
        }


{-| -}
encode : Operation t e a -> Encode.Value
encode (Operation operation) =
    case operation.kind of
        WithName name ->
            Encode.object
                (( "operationName", Encode.string name )
                    :: variablesField operation.variables
                )

        WithQuery query ->
            Encode.object
                (( "query", Encode.string query )
                    :: variablesField operation.variables
                )


variablesField : Maybe Encode.Value -> List ( String, Encode.Value )
variablesField variables =
    case variables of
        Nothing ->
            []

        Just variables ->
            [ ( "variables", variables ) ]


{-| -}
encodeParameters : Operation t e a -> List ( String, String )
encodeParameters (Operation operation) =
    case operation.kind of
        WithName name ->
            ( "operationName", encodeUri name )
                :: encodeVariablesParameter operation.variables

        WithQuery query ->
            ( "query", encodeUri query )
                :: encodeVariablesParameter operation.variables


encodeVariablesParameter : Maybe Encode.Value -> List ( String, String )
encodeVariablesParameter variables =
    case variables of
        Nothing ->
            []

        Just variables ->
            [ ( "variables", encodeUri (Encode.encode 0 variables) ) ]
