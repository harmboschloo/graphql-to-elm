module InterfaceListShared
    exposing
        ( InterfaceListSharedResponse
        , InterfaceListSharedQuery
        , Animal
        , OnAnimal(..)
        , Dog
        , Dolphin
        , Bird
        , interfaceListShared
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


interfaceListShared : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InterfaceListSharedQuery
interfaceListShared =
    GraphQL.Operation.withQuery
        """query InterfaceListShared {
animals {
color
... on Dog {
hairy
}
... on Dolphin {
fins
}
... on Bird {
canFly
}
}
}"""
        Maybe.Nothing
        interfaceListSharedQueryDecoder
        GraphQL.Errors.decoder


type alias InterfaceListSharedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InterfaceListSharedQuery


type alias InterfaceListSharedQuery =
    { animals : List Animal
    }


interfaceListSharedQueryDecoder : Json.Decode.Decoder InterfaceListSharedQuery
interfaceListSharedQueryDecoder =
    Json.Decode.map InterfaceListSharedQuery
        (Json.Decode.field "animals" (Json.Decode.list animalDecoder))


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
