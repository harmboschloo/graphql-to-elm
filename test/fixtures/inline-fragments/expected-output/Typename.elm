module Typename
    exposing
        ( TypenameQuery
        , Animal(..)
        , Dog
        , Dolphin
        , Bird
        , typename
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import Json.Decode


typename : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors TypenameQuery
typename =
    GraphqlToElm.Operation.withQuery
        """query Typename {
animal {
... on Dog {
__typename
color
}
... on Dolphin {
__typename
color
}
... on Bird {
color
}
}
}"""
        Maybe.Nothing
        typenameQueryDecoder
        GraphqlToElm.Errors.decoder


type alias TypenameQuery =
    { animal : Animal
    }


typenameQueryDecoder : Json.Decode.Decoder TypenameQuery
typenameQueryDecoder =
    Json.Decode.map TypenameQuery
        (Json.Decode.field "animal" animalDecoder)


type Animal
    = OnDog Dog
    | OnDolphin Dolphin
    | OnBird Bird


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnDolphin dolphinDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type alias Dog =
    { typename : String
    , color : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "__typename" (GraphqlToElm.Helpers.Decode.constant "Dog" Json.Decode.string))
        (Json.Decode.field "color" Json.Decode.string)


type alias Dolphin =
    { typename : String
    , color : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "__typename" (GraphqlToElm.Helpers.Decode.constant "Dolphin" Json.Decode.string))
        (Json.Decode.field "color" Json.Decode.string)


type alias Bird =
    { color : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map Bird
        (Json.Decode.field "color" Json.Decode.string)
