module CustomNullableScalarTypes
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
idOrNull
dateOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


type alias Query =
    { idOrNull : Maybe.Maybe Data.Id.Id
    , dateOrNull : Maybe.Maybe Data.Date.Date
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Data.Id.decoder))
        (Json.Decode.field "dateOrNull" (Json.Decode.nullable Data.Date.decoder))
