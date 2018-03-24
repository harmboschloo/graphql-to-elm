module Multiple
    exposing
        ( Query1Variables
        , Query
        , Operation
        , Query2
        , Operation2
        , Mutation
        , Fragment
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


query1 : Query1Variables -> GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
query1 variables =
    GraphqlToElm.Operation.query
        """query Query1($name: String) {
operation(name: $name) {
name
}
}"""
        (Maybe.Just <| encodeQuery1Variables variables)
        queryDecoder
        GraphqlToElm.Errors.decoder


query2 : GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query2
query2 =
    GraphqlToElm.Operation.query
        """query Query2 {
operation {
query
}
}"""
        Maybe.Nothing
        query2Decoder
        GraphqlToElm.Errors.decoder


mutation : GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Mutation
mutation =
    GraphqlToElm.Operation.query
        """mutation Mutation {
fragment {
name
}
}"""
        Maybe.Nothing
        mutationDecoder
        GraphqlToElm.Errors.decoder


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
    }


operationDecoder : Json.Decode.Decoder Operation
operationDecoder =
    Json.Decode.map Operation
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))


type alias Query2 =
    { operation : Maybe.Maybe Operation2
    }


query2Decoder : Json.Decode.Decoder Query2
query2Decoder =
    Json.Decode.map Query2
        (Json.Decode.field "operation" (Json.Decode.nullable operation2Decoder))


type alias Operation2 =
    { query : String
    }


operation2Decoder : Json.Decode.Decoder Operation2
operation2Decoder =
    Json.Decode.map Operation2
        (Json.Decode.field "query" Json.Decode.string)


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
