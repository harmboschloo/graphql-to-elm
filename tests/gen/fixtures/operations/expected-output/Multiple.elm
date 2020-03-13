module Multiple exposing
    ( Fragment
    , MutationMutation
    , MutationResponse
    , Operation
    , Operation2
    , Query1Query
    , Query1Response
    , Query1Variables
    , Query2Query
    , Query2Response
    , encodeQuery1Variables
    , mutation
    , query1
    , query1VariablesDecoder
    , query2
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


query1 : Query1Variables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query1Query
query1 variables =
    GraphQL.Operation.withQuery
        """query Query1($name: String) {
operation(name: $name) {
name
}
}"""
        (Maybe.Just <| encodeQuery1Variables variables)
        query1QueryDecoder
        GraphQL.Errors.decoder


query2 : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query2Query
query2 =
    GraphQL.Operation.withQuery
        """query Query2 {
operation {
query
}
}"""
        Maybe.Nothing
        query2QueryDecoder
        GraphQL.Errors.decoder


mutation : GraphQL.Operation.Operation GraphQL.Operation.Mutation GraphQL.Errors.Errors MutationMutation
mutation =
    GraphQL.Operation.withQuery
        """mutation Mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationMutationDecoder
        GraphQL.Errors.decoder


type alias Query1Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query1Query


type alias Query2Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query2Query


type alias MutationResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors MutationMutation


type alias Query1Variables =
    { name : GraphQL.Optional.Optional String
    }


encodeQuery1Variables : Query1Variables -> Json.Encode.Value
encodeQuery1Variables inputs =
    GraphQL.Optional.encodeObject
        [ ( "name", GraphQL.Optional.map Json.Encode.string inputs.name )
        ]


query1VariablesDecoder : Json.Decode.Decoder Query1Variables
query1VariablesDecoder =
    Json.Decode.map Query1Variables
        (GraphQL.Optional.fieldDecoder "name" Json.Decode.string)


type alias Query1Query =
    { operation : Maybe.Maybe Operation
    }


query1QueryDecoder : Json.Decode.Decoder Query1Query
query1QueryDecoder =
    Json.Decode.map Query1Query
        (Json.Decode.field "operation" (Json.Decode.nullable operationDecoder))


type alias Operation =
    { name : Maybe.Maybe String
    }


operationDecoder : Json.Decode.Decoder Operation
operationDecoder =
    Json.Decode.map Operation
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))


type alias Query2Query =
    { operation : Maybe.Maybe Operation2
    }


query2QueryDecoder : Json.Decode.Decoder Query2Query
query2QueryDecoder =
    Json.Decode.map Query2Query
        (Json.Decode.field "operation" (Json.Decode.nullable operation2Decoder))


type alias Operation2 =
    { query : String
    }


operation2Decoder : Json.Decode.Decoder Operation2
operation2Decoder =
    Json.Decode.map Operation2
        (Json.Decode.field "query" Json.Decode.string)


type alias MutationMutation =
    { fragment : Maybe.Maybe Fragment
    }


mutationMutationDecoder : Json.Decode.Decoder MutationMutation
mutationMutationDecoder =
    Json.Decode.map MutationMutation
        (Json.Decode.field "fragment" (Json.Decode.nullable fragmentDecoder))


type alias Fragment =
    { name : String
    }


fragmentDecoder : Json.Decode.Decoder Fragment
fragmentDecoder =
    Json.Decode.map Fragment
        (Json.Decode.field "name" Json.Decode.string)
