module MultipleFragments
    exposing
        ( Query1Variables
        , Query1Query
        , Operation
        , Query2Query
        , Operation2
        , Fragment
        , MutationMutation
        , query1
        , query2
        , mutation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import Json.Decode
import Json.Encode


query1 : Query1Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query1Query
query1 variables =
    GraphqlToElm.Operation.withQuery
        ("""query Query1($name: String) {
operation(name: $name) {
...fields1
}
}"""
            ++ fields1
        )
        (Maybe.Just <| encodeQuery1Variables variables)
        query1QueryDecoder
        GraphqlToElm.Errors.decoder


query2 : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query2Query
query2 =
    GraphqlToElm.Operation.withQuery
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
        GraphqlToElm.Errors.decoder


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors MutationMutation
mutation =
    GraphqlToElm.Operation.withQuery
        ("""mutation Mutation {
fragment {
...fields3
}
}"""
            ++ fields3
        )
        Maybe.Nothing
        mutationMutationDecoder
        GraphqlToElm.Errors.decoder


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
