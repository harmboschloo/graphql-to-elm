module FragmentInFragmentShared
    exposing
        ( Query
        , Animal
        , OnAnimal(..)
        , Mammal
        , OnMammal(..)
        , Dog
        , Dolphin
        , Bird
        , fragmentInFragmentShared
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


fragmentInFragmentShared : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
fragmentInFragmentShared =
    GraphqlToElm.Operation.withQuery
        """query FragmentInFragmentShared {
animal {
color
... on Mammal {
subclass
... on Dog {
hairy
}
... on Dolphin {
fins
}
}
... on Bird {
canFly
}
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { animal : Animal
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "animal" animalDecoder)


type alias Animal =
    { color : String
    , on : OnAnimal
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map2 Animal
        (Json.Decode.field "color" Json.Decode.string)
        onAnimalDecoder


type OnAnimal
    = OnMammal2 Mammal
    | OnBird Bird


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnMammal2 mammalDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type alias Mammal =
    { subclass : String
    , on : OnMammal
    }


mammalDecoder : Json.Decode.Decoder Mammal
mammalDecoder =
    Json.Decode.map2 Mammal
        (Json.Decode.field "subclass" Json.Decode.string)
        onMammalDecoder


type OnMammal
    = OnDog Dog
    | OnDolphin Dolphin


onMammalDecoder : Json.Decode.Decoder OnMammal
onMammalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnDolphin dolphinDecoder
        ]


type alias Dog =
    { hairy : Bool
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "hairy" Json.Decode.bool)


type alias Dolphin =
    { fins : Int
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map Dolphin
        (Json.Decode.field "fins" Json.Decode.int)


type alias Bird =
    { canFly : Bool
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map Bird
        (Json.Decode.field "canFly" Json.Decode.bool)
