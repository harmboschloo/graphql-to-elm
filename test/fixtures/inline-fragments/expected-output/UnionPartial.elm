module UnionPartial
    exposing
        ( Query
        , Flip(..)
        , Heads
        , Flip2(..)
        , Tails
        , unionPartial
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import Json.Decode


unionPartial : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
unionPartial =
    GraphqlToElm.Operation.withQuery
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
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { flip : Flip
    , flipOrNull : Maybe.Maybe Flip2
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "flip" flipDecoder)
        (Json.Decode.field "flipOrNull" (Json.Decode.nullable flip2Decoder))


type Flip
    = OnHeads Heads
    | OnOtherFlip


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherFlip
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
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherFlip2
        ]


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
