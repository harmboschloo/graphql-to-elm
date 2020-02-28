module TypenameMixed exposing
    ( Animal(..)
    , Bird
    , Dog
    , Dolphin
    , Mammal(..)
    , TypenameMixedQuery
    , TypenameMixedResponse
    , typenameMixed
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameMixed : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameMixedQuery
typenameMixed =
    GraphQL.Operation.withQuery
        """query TypenameMixed {
animal {
__typename
... on Mammal {
__typename
}
}
}"""
        Maybe.Nothing
        typenameMixedQueryDecoder
        GraphQL.Errors.decoder


type alias TypenameMixedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameMixedQuery


type alias TypenameMixedQuery =
    { animal : Animal
    }


typenameMixedQueryDecoder : Json.Decode.Decoder TypenameMixedQuery
typenameMixedQueryDecoder =
    Json.Decode.map TypenameMixedQuery
        (Json.Decode.field "animal" animalDecoder)


type Animal
    = OnMammal Mammal
    | OnBird Bird


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
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
