module Union
    exposing
        ( Query
        , Flip(..)
        , Heads
        , Tails
        , union
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


union : GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
union =
    GraphqlToElm.Operation.query
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
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { flip : Flip
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
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
