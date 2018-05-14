module Queries.Messages
    exposing
        ( Response
        , Query
        , Message
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
messages {
message
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { messages : List Message
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))


type alias Message =
    { message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map Message
        (Json.Decode.field "message" Json.Decode.string)
