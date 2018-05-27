module Enum
    exposing
        ( Response
        , Query
        , query
        )

import Data.Binary
import GraphQL.Enum.UserType
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
binary
userType
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { binary : Data.Binary.Binary
    , userType : GraphQL.Enum.UserType.UserType
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "binary" Data.Binary.decoder)
        (Json.Decode.field "userType" GraphQL.Enum.UserType.decoder)
