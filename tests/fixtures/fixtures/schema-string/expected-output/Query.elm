module Query exposing
    ( Query
    , Response
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
hello
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { hello : String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "hello" Json.Decode.string)
