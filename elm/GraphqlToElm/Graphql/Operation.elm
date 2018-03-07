module GraphqlToElm.Graphql.Operation
    exposing
        ( Operation
        , named
        , query
        , dataDecoder
        , mapData
        , errorsDecoder
        , mapErrors
        , encode
        , encodeParameters
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Http exposing (encodeUri)


type Operation e a
    = Operation
        { type_ : Type
        , variables : Maybe Encode.Value
        , dataDecoder : Decoder a
        , errorsDecoder : Decoder e
        }


type Type
    = Named String
    | Query String


named : String -> Maybe Encode.Value -> Decoder a -> Decoder e -> Operation e a
named name =
    operation (Named name)


query : String -> Maybe Encode.Value -> Decoder a -> Decoder e -> Operation e a
query queryString =
    operation (Query queryString)


operation :
    Type
    -> Maybe Encode.Value
    -> Decoder a
    -> Decoder e
    -> Operation e a
operation type_ variables dataDecoder errorsDecoder =
    Operation
        { type_ = type_
        , variables = variables
        , dataDecoder = dataDecoder
        , errorsDecoder = errorsDecoder
        }


dataDecoder : Operation e a -> Decoder a
dataDecoder (Operation operation) =
    operation.dataDecoder


mapData : (a -> b) -> Operation e a -> Operation e b
mapData mapper (Operation operation) =
    Operation
        { operation | dataDecoder = Decode.map mapper operation.dataDecoder }


errorsDecoder : Operation e a -> Decoder e
errorsDecoder (Operation operation) =
    operation.errorsDecoder


mapErrors : (e1 -> e2) -> Operation e1 a -> Operation e2 a
mapErrors mapper (Operation operation) =
    Operation
        { operation
            | errorsDecoder = Decode.map mapper operation.errorsDecoder
        }


encode : Operation e a -> Encode.Value
encode (Operation operation) =
    case operation.type_ of
        Named name ->
            Encode.object
                (( "operationName", Encode.string name )
                    :: variablesField operation.variables
                )

        Query query ->
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


encodeParameters : Operation e a -> List ( String, String )
encodeParameters (Operation operation) =
    case operation.type_ of
        Named name ->
            ( "operationName", encodeUri name )
                :: encodeVariablesParameter operation.variables

        Query query ->
            ( "query", encodeUri query )
                :: encodeVariablesParameter operation.variables


encodeVariablesParameter : Maybe Encode.Value -> List ( String, String )
encodeVariablesParameter variables =
    case variables of
        Nothing ->
            []

        Just variables ->
            [ ( "variables", encodeUri (Encode.encode 0 variables) ) ]
