module TypenameOnly exposing
    ( Animal(..)
    , Bird
    , Dog
    , Dolphin
    , Flip(..)
    , Heads
    , Tails
    , TypenameOnlyQuery
    , TypenameOnlyResponse
    , typenameOnly
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameOnly : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameOnlyQuery
typenameOnly =
    GraphQL.Operation.withQuery
        """query TypenameOnly {
flip {
__typename
}
animal {
__typename
}
}"""
        Maybe.Nothing
        typenameOnlyQueryDecoder
        GraphQL.Errors.decoder


type alias TypenameOnlyResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameOnlyQuery


type alias TypenameOnlyQuery =
    { flip : Flip
    , animal : Animal
    }


typenameOnlyQueryDecoder : Json.Decode.Decoder TypenameOnlyQuery
typenameOnlyQueryDecoder =
    Json.Decode.map2 TypenameOnlyQuery
        (Json.Decode.field "flip" flipDecoder)
        (Json.Decode.field "animal" animalDecoder)


type Flip
    = OnHeads Heads
    | OnTails Tails


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , Json.Decode.map OnTails tailsDecoder
        ]


type alias Heads =
    { typename__ : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Heads"))


type alias Tails =
    { typename__ : String
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Tails"))


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
