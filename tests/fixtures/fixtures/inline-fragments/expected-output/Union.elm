module Union
    exposing
        ( UnionResponse
        , UnionQuery
        , Flip(..)
        , Heads
        , Tails
        , union
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


union : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UnionQuery
union =
    GraphQL.Operation.withQuery
        """query Union {
flip {
... on Heads {
name
}
... on Tails {
length
}
}
}"""
        Maybe.Nothing
        unionQueryDecoder
        GraphQL.Errors.decoder


type alias UnionResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UnionQuery


type alias UnionQuery =
    { flip : Flip
    }


unionQueryDecoder : Json.Decode.Decoder UnionQuery
unionQueryDecoder =
    Json.Decode.map UnionQuery
        (Json.Decode.field "flip" flipDecoder)


type Flip
    = OnHeads Heads
    | OnTails Tails


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , Json.Decode.map OnTails tailsDecoder
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
