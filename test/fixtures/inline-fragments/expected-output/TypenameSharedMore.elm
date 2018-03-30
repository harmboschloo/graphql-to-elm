module TypenameSharedMore
    exposing
        ( TypenameSharedMoreResponse
        , TypenameSharedMoreQuery
        , Animal
        , OnAnimal(..)
        , Dog
        , Dolphin
        , Bird
        , typenameSharedMore
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


typenameSharedMore : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors TypenameSharedMoreQuery
typenameSharedMore =
    GraphqlToElm.Operation.withQuery
        """query TypenameSharedMore {
animal {
__typename
size
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
        typenameSharedMoreQueryDecoder
        GraphqlToElm.Errors.decoder


type alias TypenameSharedMoreResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors TypenameSharedMoreQuery


type alias TypenameSharedMoreQuery =
    { animal : Animal
    }


typenameSharedMoreQueryDecoder : Json.Decode.Decoder TypenameSharedMoreQuery
typenameSharedMoreQueryDecoder =
    Json.Decode.map TypenameSharedMoreQuery
        (Json.Decode.field "animal" animalDecoder)


type alias Animal =
    { size : Float
    , on : OnAnimal
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map2 Animal
        (Json.Decode.field "size" Json.Decode.float)
        onAnimalDecoder


type OnAnimal
    = OnDog Dog
    | OnDolphin Dolphin
    | OnBird Bird


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
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
