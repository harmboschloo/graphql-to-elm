module AnonymousMutation
    exposing
        ( Mutation
        , Fragment
        , mutation
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


mutation : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Mutation
mutation =
    GraphqlToElm.Graphql.Operation.query
        """mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationDecoder
        GraphqlToElm.Graphql.Errors.decoder


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
