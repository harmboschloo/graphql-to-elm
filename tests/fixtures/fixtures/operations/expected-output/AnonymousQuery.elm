module AnonymousQuery
    exposing
        ( Response
        , Query
        , Operation
        , query
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
operation {
query
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { operation : Maybe.Maybe Operation
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "operation" (Json.Decode.nullable operationDecoder))


type alias Operation =
    { query : String
    }


operationDecoder : Json.Decode.Decoder Operation
operationDecoder =
    Json.Decode.map Operation
        (Json.Decode.field "query" Json.Decode.string)
