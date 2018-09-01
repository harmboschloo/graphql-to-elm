module InterfacePartialShared exposing
    ( Animal
    , Dog
    , InterfacePartialSharedQuery
    , InterfacePartialSharedResponse
    , OnAnimal(..)
    , interfacePartialShared
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


interfacePartialShared : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InterfacePartialSharedQuery
interfacePartialShared =
    GraphQL.Operation.withQuery
        """query InterfacePartialShared {
animal {
color
... on Dog {
hairy
}
}
}"""
        Maybe.Nothing
        interfacePartialSharedQueryDecoder
        GraphQL.Errors.decoder


type alias InterfacePartialSharedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InterfacePartialSharedQuery


type alias InterfacePartialSharedQuery =
    { animal : Animal
    }


interfacePartialSharedQueryDecoder : Json.Decode.Decoder InterfacePartialSharedQuery
interfacePartialSharedQueryDecoder =
    Json.Decode.map InterfacePartialSharedQuery
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
