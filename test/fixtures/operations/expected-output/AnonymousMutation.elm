module AnonymousMutation exposing
    ( Fragment
    , Mutation
    , Response
    , mutation
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


mutation : GraphQL.Operation.Operation GraphQL.Operation.Mutation GraphQL.Errors.Errors Mutation
mutation =
    GraphQL.Operation.withQuery
        """mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Mutation


type alias Mutation =
    { fragment : Maybe.Maybe Fragment
    }


mutationDecoder : Json.Decode.Decoder Mutation
mutationDecoder =
    Json.Decode.map Mutation
        (Json.Decode.field "fragment" (Json.Decode.nullable fragmentDecoder))


type alias Fragment =
    { name : String
    }


fragmentDecoder : Json.Decode.Decoder Fragment
fragmentDecoder =
    Json.Decode.map Fragment
        (Json.Decode.field "name" Json.Decode.string)
