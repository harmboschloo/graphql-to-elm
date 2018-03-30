module Query
    exposing
        ( Query1Response
        , Query1Variables
        , Query1Query
        , Operation
        , Query2Response
        , Query2Query
        , Operation2
        , MutationResponse
        , MutationMutation
        , Fragment
        , query1
        , query2
        , mutation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import GraphqlToElm.Response
import Json.Decode
import Json.Encode


query1 : Query1Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query1Query
query1 variables =
    GraphqlToElm.Operation.withName
        "Query1"
        (Maybe.Just <| encodeQuery1Variables variables)
        query1QueryDecoder
        GraphqlToElm.Errors.decoder


query2 : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query2Query
query2 =
    GraphqlToElm.Operation.withName
        "Query2"
        Maybe.Nothing
        query2QueryDecoder
        GraphqlToElm.Errors.decoder


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors MutationMutation
mutation =
    GraphqlToElm.Operation.withName
        "Mutation"
        Maybe.Nothing
        mutationMutationDecoder
        GraphqlToElm.Errors.decoder


type alias Query1Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query1Query


type alias Query2Response =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors Query2Query


type alias MutationResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors MutationMutation


type alias Query1Variables =
    { name : GraphqlToElm.Optional.Optional String
    }


encodeQuery1Variables : Query1Variables -> Json.Encode.Value
encodeQuery1Variables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "name", (GraphqlToElm.Optional.map Json.Encode.string) inputs.name )
        ]


type alias Query1Query =
    { operation : Maybe.Maybe Operation
    }


query1QueryDecoder : Json.Decode.Decoder Query1Query
query1QueryDecoder =
    Json.Decode.map Query1Query
        (Json.Decode.field "operation" (Json.Decode.nullable operationDecoder))


type alias Operation =
    { name : Maybe.Maybe String
    , fragmentNames : Maybe.Maybe (List String)
    }


operationDecoder : Json.Decode.Decoder Operation
operationDecoder =
    Json.Decode.map2 Operation
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "fragmentNames" (Json.Decode.nullable (Json.Decode.list Json.Decode.string)))


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
