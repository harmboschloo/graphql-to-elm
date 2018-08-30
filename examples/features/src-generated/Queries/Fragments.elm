module Queries.Fragments exposing
    ( Message
    , Query
    , Response
    , User
    , query
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        ("""query {
user {
...userFields
}
lastMessage {
...messageFields
}
messages {
...messageFields
}
}"""
            ++ userFields
            ++ messageFields
        )
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


userFields : String
userFields =
    """fragment userFields on User {
id
name
email
}"""


messageFields : String
messageFields =
    """fragment messageFields on Message {
id
from {
...userFields
}
message
}"""


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { user : User
    , lastMessage : Maybe.Maybe Message
    , messages : List Message
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map3 Query
        (Json.Decode.field "user" userDecoder)
        (Json.Decode.field "lastMessage" (Json.Decode.nullable messageDecoder))
        (Json.Decode.field "messages" (Json.Decode.list messageDecoder))


type alias User =
    { id : String
    , name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias Message =
    { id : String
    , from : User
    , message : String
    }


messageDecoder : Json.Decode.Decoder Message
messageDecoder =
    Json.Decode.map3 Message
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "from" userDecoder)
        (Json.Decode.field "message" Json.Decode.string)
