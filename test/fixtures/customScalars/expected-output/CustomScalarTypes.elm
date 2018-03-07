module CustomScalarTypes
    exposing
        ( Query
        , query
        )

import Data.Date
import Data.Id
import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
        """{
id
date
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Query =
    { id : Data.Id.Id
    , date : Data.Date.Date
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "id" Data.Id.decoder)
        (Json.Decode.field "date" Data.Date.decoder)
