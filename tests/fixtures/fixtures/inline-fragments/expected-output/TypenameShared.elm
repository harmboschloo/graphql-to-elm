module TypenameShared exposing
    ( Animal(..)
    , Bird
    , Dog
    , Dolphin
    , TypenameSharedQuery
    , TypenameSharedResponse
    , typenameShared
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


typenameShared : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TypenameSharedQuery
typenameShared =
    GraphQL.Operation.withQuery
        """query TypenameShared {
animal {
__typename
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
        typenameSharedQueryDecoder
        GraphQL.Errors.decoder


type alias TypenameSharedResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TypenameSharedQuery


type alias TypenameSharedQuery =
    { animal : Animal
    }


typenameSharedQueryDecoder : Json.Decode.Decoder TypenameSharedQuery
typenameSharedQueryDecoder =
    Json.Decode.map TypenameSharedQuery
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
    , typename__ : String
    }


dogDecoder : Json.Decode.Decoder Dog
dogDecoder =
    Json.Decode.map2 Dog
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dog"))


type alias Dolphin =
    { color : String
    , typename__ : String
    }


dolphinDecoder : Json.Decode.Decoder Dolphin
dolphinDecoder =
    Json.Decode.map2 Dolphin
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Dolphin"))


type alias Bird =
    { color : String
    , typename__ : String
    }


birdDecoder : Json.Decode.Decoder Bird
birdDecoder =
    Json.Decode.map2 Bird
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constantString "Bird"))
