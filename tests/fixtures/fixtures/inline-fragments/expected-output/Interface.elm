module Interface exposing
    ( Animal(..)
    , Bird
    , Dog
    , Dolphin
    , InterfaceQuery
    , InterfaceResponse
    , interface
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


interface : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InterfaceQuery
interface =
    GraphQL.Operation.withQuery
        """query Interface {
animal {
... on Dog {
color
hairy
}
... on Dolphin {
color
fins
}
... on Bird {
color
canFly
}
}
}"""
        Maybe.Nothing
        interfaceQueryDecoder
        GraphQL.Errors.decoder


type alias InterfaceResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InterfaceQuery


type alias InterfaceQuery =
    { animal : Animal
    }


interfaceQueryDecoder : Json.Decode.Decoder InterfaceQuery
interfaceQueryDecoder =
    Json.Decode.map InterfaceQuery
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
    , hairy : Bool
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "hairy" Json.Decode.bool)


type alias Dolphin =
    { color : String
    , fins : Int
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "fins" Json.Decode.int)


type alias Bird =
    { color : String
    , canFly : Bool
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "canFly" Json.Decode.bool)
