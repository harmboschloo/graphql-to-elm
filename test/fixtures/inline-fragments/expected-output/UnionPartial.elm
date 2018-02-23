module UnionPartial
    exposing
        ( Data
        , FlipUnion(..)
        , Heads
        , Flip
        , query
        , decoder
        )

import Json.Decode


query : String
query =
    """query UnionPartial {
  flip {
    ... on Heads {
      name
    }
  }
}"""


type alias Data =
    { flip : FlipUnion
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "flip" flipUnionDecoder)


type FlipUnion
    = OnHeads Heads
    | OnFlip Flip


flipUnionDecoder : Json.Decode.Decoder FlipUnion
flipUnionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , Json.Decode.map OnFlip flipDecoder
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type alias Flip =
    {}


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.keyValuePairs Json.Decode.value
        |> Json.Decode.andThen
            (\pairs ->
                if List.isEmpty pairs then
                    Json.Decode.succeed Flip
                else
                    Json.Decode.fail "expected empty object"
            )