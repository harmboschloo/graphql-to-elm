module TypenameSharedMore exposing
    ( Animal
    , Bird
    , Dog
    , Dolphin
    , OnAnimal(..)
    , TypenameSharedMoreQuery
    , TypenameSharedMoreResponse
    , typenameSharedMore
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameSharedMore : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameSharedMoreQuery
typenameSharedMore =
    GraphQL.Operation.withQuery
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
        GraphQL.Errors.decoder


type alias TypenameSharedMoreResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameSharedMoreQuery


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
    , typename__ : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constant "Dog" Json.Decode.string))


type alias Dolphin =
    { color : String
    , typename__ : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constant "Dolphin" Json.Decode.string))


type alias Bird =
    { color : String
    , typename__ : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constant "Bird" Json.Decode.string))
