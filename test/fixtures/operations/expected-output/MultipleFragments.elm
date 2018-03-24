module MultipleFragments
    exposing
        ( Query1Variables
        , Query
        , Operation
        , Query2
        , Operation2
        , Fragment
        , Mutation
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


query1 : Query1Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query1 variables =
    GraphqlToElm.Operation.query
        ("""query Query1($name: String) {
operation(name: $name) {
...fields1
}
}"""
            ++ fields1
        )
        (Maybe.Just <| encodeQuery1Variables variables)
        queryDecoder
        GraphqlToElm.Errors.decoder


query2 : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query2
query2 =
    GraphqlToElm.Operation.query
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
        query2Decoder
        GraphqlToElm.Errors.decoder


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Mutation GraphqlToElm.Errors.Errors Mutation
mutation =
    GraphqlToElm.Operation.query
        ("""mutation Mutation {
fragment {
...fields3
}
}"""
            ++ fields3
        )
        Maybe.Nothing
        mutationDecoder
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


type alias Query =
    { operation : Maybe.Maybe Operation
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
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


type alias Query2 =
    { operation : Maybe.Maybe Operation2
    , current : Operation2
    , fragment : Fragment
    }


query2Decoder : Json.Decode.Decoder Query2
query2Decoder =
    Json.Decode.map3 Query2
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


type alias Mutation =
    { fragment : Maybe.Maybe Fragment
    }


mutationDecoder : Json.Decode.Decoder Mutation
mutationDecoder =
    Json.Decode.map Mutation
        (Json.Decode.field "fragment" (Json.Decode.nullable fragmentDecoder))
