module AnonymousMutation
    exposing
        ( Mutation
        , Fragment
        , mutation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Mutation
mutation =
    GraphqlToElm.Operation.query
        """mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationDecoder
        GraphqlToElm.Errors.decoder


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
