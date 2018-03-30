module TypenameShared
    exposing
        ( TypenameSharedResponse
        , TypenameSharedQuery
        , Animal(..)
        , Dog
        , Dolphin
        , Bird
        , typenameShared
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


typenameShared : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors TypenameSharedQuery
typenameShared =
    GraphqlToElm.Operation.withQuery
        """query TypenameShared {
animal {
__typename
... on Dog {
color
}
... on Dolphin {
color
}
... on Bird {
color
}
}
}"""
        Maybe.Nothing
        typenameSharedQueryDecoder
        GraphqlToElm.Errors.decoder


type alias TypenameSharedResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors TypenameSharedQuery


type alias TypenameSharedQuery =
    { animal : Animal
    }


typenameSharedQueryDecoder : Json.Decode.Decoder TypenameSharedQuery
typenameSharedQueryDecoder =
    Json.Decode.map TypenameSharedQuery
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
    { color : String
    , typename : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.Helpers.Decode.constant "Dog" Json.Decode.string))


type alias Dolphin =
    { color : String
    , typename : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.Helpers.Decode.constant "Dolphin" Json.Decode.string))


type alias Bird =
    { color : String
    , typename : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphqlToElm.Helpers.Decode.constant "Bird" Json.Decode.string))
