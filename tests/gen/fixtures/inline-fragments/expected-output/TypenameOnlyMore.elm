module TypenameOnlyMore exposing
    ( Animal
    , Bird
    , Dog
    , Dolphin
    , OnAnimal(..)
    , TypenameOnlyMoreQuery
    , TypenameOnlyMoreResponse
    , typenameOnlyMore
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameOnlyMore : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameOnlyMoreQuery
typenameOnlyMore =
    GraphQL.Operation.withQuery
        """query TypenameOnlyMore {
animal {
__typename
color
}
}"""
        Maybe.Nothing
        typenameOnlyMoreQueryDecoder
        GraphQL.Errors.decoder


type alias TypenameOnlyMoreResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameOnlyMoreQuery


type alias TypenameOnlyMoreQuery =
    { animal : Animal
    }


typenameOnlyMoreQueryDecoder : Json.Decode.Decoder TypenameOnlyMoreQuery
typenameOnlyMoreQueryDecoder =
    Json.Decode.map TypenameOnlyMoreQuery
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
    { typename__ : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dog"))


type alias Dolphin =
    { typename__ : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map Dolphin
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dolphin"))


type alias Bird =
    { typename__ : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map Bird
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Bird"))
