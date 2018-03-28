module FragmentInFragmentPartial
    exposing
        ( FragmentInFragmentPartialQuery
        , Animal
        , OnAnimal(..)
        , Mammal(..)
        , Dog
        , fragmentInFragmentPartial
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import Json.Decode


fragmentInFragmentPartial : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors FragmentInFragmentPartialQuery
fragmentInFragmentPartial =
    GraphqlToElm.Operation.withQuery
        """query FragmentInFragmentPartial {
animal {
color
... on Mammal {
... on Dog {
hairy
}
}
}
}"""
        Maybe.Nothing
        fragmentInFragmentPartialQueryDecoder
        GraphqlToElm.Errors.decoder


type alias FragmentInFragmentPartialQuery =
    { animal : Animal
    }


fragmentInFragmentPartialQueryDecoder : Json.Decode.Decoder FragmentInFragmentPartialQuery
fragmentInFragmentPartialQueryDecoder =
    Json.Decode.map FragmentInFragmentPartialQuery
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
    | OnOtherAnimal


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnMammal mammalDecoder
        , Json.Decode.succeed OnOtherAnimal
        ]


type Mammal
    = OnDog Dog
    | OnOtherMammal


mammalDecoder : Json.Decode.Decoder Mammal
mammalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherMammal
        ]


type alias Dog =
    { hairy : Bool
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "hairy" Json.Decode.bool)
