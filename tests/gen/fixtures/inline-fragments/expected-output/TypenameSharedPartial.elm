module TypenameSharedPartial exposing
    ( Animal(..)
    , Bird
    , Dog
    , Dolphin
    , TypenameSharedPartialQuery
    , TypenameSharedPartialResponse
    , typenameSharedPartial
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameSharedPartial : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameSharedPartialQuery
typenameSharedPartial =
    GraphQL.Operation.withQuery
        """query TypenameSharedPartial {
animal {
__typename
... on Dolphin {
color
}
}
}"""
        Maybe.Nothing
        typenameSharedPartialQueryDecoder
        GraphQL.Errors.decoder


type alias TypenameSharedPartialResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameSharedPartialQuery


type alias TypenameSharedPartialQuery =
    { animal : Animal
    }


typenameSharedPartialQueryDecoder : Json.Decode.Decoder TypenameSharedPartialQuery
typenameSharedPartialQueryDecoder =
    Json.Decode.map TypenameSharedPartialQuery
        (Json.Decode.field "animal" animalDecoder)


type Animal
    = OnDolphin Dolphin
    | OnDog Dog
    | OnBird Bird


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDolphin dolphinDecoder
        , Json.Decode.map OnDog dogDecoder
        , Json.Decode.map OnBird birdDecoder
        ]


type alias Dolphin =
    { color : String
    , typename__ : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dolphin"))


type alias Dog =
    { typename__ : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map Dog
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dog"))


type alias Bird =
    { typename__ : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map Bird
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Bird"))
