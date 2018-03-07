module CustomNullableScalarTypes
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
idOrNull
dateOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Query =
    { idOrNull : Maybe.Maybe Data.Id.Id
    , dateOrNull : Maybe.Maybe Data.Date.Date
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "idOrNull" (Json.Decode.nullable Data.Id.decoder))
        (Json.Decode.field "dateOrNull" (Json.Decode.nullable Data.Date.decoder))
