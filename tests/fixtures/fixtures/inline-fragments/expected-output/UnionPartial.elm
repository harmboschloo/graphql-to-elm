module UnionPartial exposing
    ( Flip(..)
    , Flip2(..)
    , Heads
    , Tails
    , UnionPartialQuery
    , UnionPartialResponse
    , unionPartial
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


unionPartial : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UnionPartialQuery
unionPartial =
    GraphQL.Operation.withQuery
        """query UnionPartial {
flip {
... on Heads {
name
}
}
flipOrNull {
... on Tails {
length
}
}
}"""
        Maybe.Nothing
        unionPartialQueryDecoder
        GraphQL.Errors.decoder


type alias UnionPartialResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UnionPartialQuery


type alias UnionPartialQuery =
    { flip : Flip
    , flipOrNull : Maybe.Maybe Flip2
    }


unionPartialQueryDecoder : Json.Decode.Decoder UnionPartialQuery
unionPartialQueryDecoder =
    Json.Decode.map2 UnionPartialQuery
        (Json.Decode.field "flip" flipDecoder)
        (Json.Decode.field "flipOrNull" (Json.Decode.nullable flip2Decoder))


type Flip
    = OnHeads Heads
    | OnOtherFlip


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , GraphQL.Helpers.Decode.emptyObject OnOtherFlip
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type Flip2
    = OnTails Tails
    | OnOtherFlip2


flip2Decoder : Json.Decode.Decoder Flip2
flip2Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnTails tailsDecoder
        , GraphQL.Helpers.Decode.emptyObject OnOtherFlip2
        ]


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
