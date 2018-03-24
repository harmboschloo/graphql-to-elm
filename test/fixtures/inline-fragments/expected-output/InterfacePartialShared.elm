module InterfacePartialShared
    exposing
        ( Query
        , Animal
        , OnAnimal(..)
        , Dog
        , interfacePartialShared
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


interfacePartialShared : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
interfacePartialShared =
    GraphqlToElm.Operation.query
        """query InterfacePartialShared {
animal {
color
... on Dog {
hairy
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
    = OnDog Dog
    | OnOtherAnimal


onAnimalDecoder : Json.Decode.Decoder OnAnimal
onAnimalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , Json.Decode.succeed OnOtherAnimal
        ]


type alias Dog =
    { hairy : Bool
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "hairy" Json.Decode.bool)
