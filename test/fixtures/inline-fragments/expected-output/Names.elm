module Names
    exposing
        ( NamesQuery
        , Flip(..)
        , Heads
        , Tails
        , Flip2(..)
        , Flip3(..)
        , names
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import Json.Decode


names : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors NamesQuery
names =
    GraphqlToElm.Operation.withQuery
        """query Names {
flip1: flip {
... on Heads {
name
}
... on Tails {
length
}
}
flip2: flip {
... on Heads {
name
}
... on Tails {
length
}
}
flip3: flip {
... on Heads {
name
}
}
flip4: flip {
... on Tails {
length
}
}
}"""
        Maybe.Nothing
        namesQueryDecoder
        GraphqlToElm.Errors.decoder


type alias NamesQuery =
    { flip1 : Flip
    , flip2 : Flip
    , flip3 : Flip2
    , flip4 : Flip3
    }


namesQueryDecoder : Json.Decode.Decoder NamesQuery
namesQueryDecoder =
    Json.Decode.map4 NamesQuery
        (Json.Decode.field "flip1" flipDecoder)
        (Json.Decode.field "flip2" flipDecoder)
        (Json.Decode.field "flip3" flip2Decoder)
        (Json.Decode.field "flip4" flip3Decoder)


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


type Flip2
    = OnHeads2 Heads
    | OnOtherFlip


flip2Decoder : Json.Decode.Decoder Flip2
flip2Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads2 headsDecoder
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherFlip
        ]


type Flip3
    = OnTails2 Tails
    | OnOtherFlip2


flip3Decoder : Json.Decode.Decoder Flip3
flip3Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnTails2 tailsDecoder
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherFlip2
        ]
