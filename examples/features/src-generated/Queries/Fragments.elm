module Queries.Fragments
    exposing
        ( Response
        , Query
        , User
        , Message
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.withQuery
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
        GraphqlToElm.Errors.decoder


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
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query


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
