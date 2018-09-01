module CustomScalarTypes exposing
    ( Query
    , Response
    , query
    )

import Data.Id
import Data.Time
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
id
time
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { id : Data.Id.Id
    , time : Data.Time.Posix
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "id" Data.Id.decoder)
        (Json.Decode.field "time" Data.Time.decoder)
