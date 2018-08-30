module FragmentInFragment exposing
    ( Animal
    , Bird
    , Dog
    , Dolphin
    , FragmentInFragmentQuery
    , FragmentInFragmentResponse
    , Mammal(..)
    , OnAnimal(..)
    , fragmentInFragment
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


fragmentInFragment : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors FragmentInFragmentQuery
fragmentInFragment =
    GraphQL.Operation.withQuery
        """query FragmentInFragment {
animal {
color
... on Mammal {
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
        fragmentInFragmentQueryDecoder
        GraphQL.Errors.decoder


type alias FragmentInFragmentResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors FragmentInFragmentQuery


type alias FragmentInFragmentQuery =
    { animal : Animal
    }


fragmentInFragmentQueryDecoder : Json.Decode.Decoder FragmentInFragmentQuery
fragmentInFragmentQueryDecoder =
    Json.Decode.map FragmentInFragmentQuery
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
    = OnMammal Mammal
    | OnBird Bird


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnMammal mammalDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type Mammal
    = OnDog Dog
    | OnDolphin Dolphin


mammalDecoder : Json.Decode.Decoder Mammal
mammalDecoder =
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
