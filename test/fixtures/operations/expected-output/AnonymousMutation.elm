module AnonymousMutation
    exposing
        ( Response
        , Mutation
        , Fragment
        , mutation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors Mutation
mutation =
    GraphqlToElm.Operation.withQuery
        """mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationDecoder
        GraphqlToElm.Errors.decoder


type alias Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Mutation


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
