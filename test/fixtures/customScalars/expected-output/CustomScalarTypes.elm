module CustomScalarTypes
    exposing
        ( Response
        , Query
        , query
        )

import Data.Date
import Data.Id
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
id
date
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { id : Data.Id.Id
    , date : Data.Date.Date
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "id" Data.Id.decoder)
        (Json.Decode.field "date" Data.Date.decoder)
