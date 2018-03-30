module CustomScalarTypes
    exposing
        ( Response
        , Query
        , query
        )

import Data.Date
import Data.Id
import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
        """{
id
date
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { id : Data.Id.Id
    , date : Data.Date.Date
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "id" Data.Id.decoder)
        (Json.Decode.field "date" Data.Date.decoder)
