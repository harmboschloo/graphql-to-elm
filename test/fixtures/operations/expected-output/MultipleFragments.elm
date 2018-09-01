module MultipleFragments exposing
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
    , mutation
    , query1
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
        ("""query Query1($name: String) {
operation(name: $name) {
...fields1
}
}"""
            ++ fields1
        )
        (Maybe.Just <| encodeQuery1Variables variables)
        query1QueryDecoder
        GraphQL.Errors.decoder


query2 : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query2Query
query2 =
    GraphQL.Operation.withQuery
        ("""query Query2 {
operation {
...fields2
}
current {
...fields2
}
fragment {
...fields3
}
}"""
            ++ fields2
            ++ fields3
        )
        Maybe.Nothing
        query2QueryDecoder
        GraphQL.Errors.decoder


mutation : GraphQL.Operation.Operation GraphQL.Operation.Mutation GraphQL.Errors.Errors MutationMutation
mutation =
    GraphQL.Operation.withQuery
        ("""mutation Mutation {
fragment {
...fields3
}
}"""
            ++ fields3
        )
        Maybe.Nothing
        mutationMutationDecoder
        GraphQL.Errors.decoder


fields1 : String
fields1 =
    """fragment fields1 on Operation {
name
fragmentNames
}"""


fields2 : String
fields2 =
    """fragment fields2 on Operation {
query
}"""


fields3 : String
fields3 =
    """fragment fields3 on Fragment {
name
}"""


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
    , current : Operation2
    , fragment : Fragment
    }


query2QueryDecoder : Json.Decode.Decoder Query2Query
query2QueryDecoder =
    Json.Decode.map3 Query2Query
        (Json.Decode.field "operation" (Json.Decode.nullable operation2Decoder))
        (Json.Decode.field "current" operation2Decoder)
        (Json.Decode.field "fragment" fragmentDecoder)


type alias Operation2 =
    { query : String
    }


operation2Decoder : Json.Decode.Decoder Operation2
operation2Decoder =
    Json.Decode.map Operation2
        (Json.Decode.field "query" Json.Decode.string)


type alias Fragment =
    { name : String
    }


fragmentDecoder : Json.Decode.Decoder Fragment
fragmentDecoder =
    Json.Decode.map Fragment
        (Json.Decode.field "name" Json.Decode.string)


type alias MutationMutation =
    { fragment : Maybe.Maybe Fragment
    }


mutationMutationDecoder : Json.Decode.Decoder MutationMutation
mutationMutationDecoder =
    Json.Decode.map MutationMutation
        (Json.Decode.field "fragment" (Json.Decode.nullable fragmentDecoder))
