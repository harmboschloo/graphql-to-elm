module MyQuery exposing
    ( User
    , UserNameQuery
    , UserNameResponse
    , userName
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


userName : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UserNameQuery
userName =
    GraphQL.Operation.withQuery
        """query UserName {
user {
name
}
}"""
        Maybe.Nothing
        userNameQueryDecoder
        GraphQL.Errors.decoder


type alias UserNameResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UserNameQuery


type alias UserNameQuery =
    { user : User
    }


userNameQueryDecoder : Json.Decode.Decoder UserNameQuery
userNameQueryDecoder =
    Json.Decode.map UserNameQuery
        (Json.Decode.field "user" userDecoder)


type alias User =
    { name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map User
        (Json.Decode.field "name" Json.Decode.string)
