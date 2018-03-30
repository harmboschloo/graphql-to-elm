module UnionList
    exposing
        ( UnionListResponse
        , UnionListQuery
        , Flip(..)
        , Heads
        , Tails
        , unionList
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


unionList : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors UnionListQuery
unionList =
    GraphqlToElm.Operation.withQuery
        """query UnionList {
flips {
... on Heads {
name
}
... on Tails {
length
}
}
}"""
        Maybe.Nothing
        unionListQueryDecoder
        GraphqlToElm.Errors.decoder


type alias UnionListResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors UnionListQuery


type alias UnionListQuery =
    { flips : List Flip
    }


unionListQueryDecoder : Json.Decode.Decoder UnionListQuery
unionListQueryDecoder =
    Json.Decode.map UnionListQuery
        (Json.Decode.field "flips" (Json.Decode.list flipDecoder))


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
