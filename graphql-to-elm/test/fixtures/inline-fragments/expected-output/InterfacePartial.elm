module InterfacePartial exposing
    ( Animal(..)
    , Dog
    , InterfacePartialQuery
    , InterfacePartialResponse
    , interfacePartial
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


interfacePartial : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InterfacePartialQuery
interfacePartial =
    GraphQL.Operation.withQuery
        """query InterfacePartial {
animal {
... on Dog {
color
hairy
}
}
}"""
        Maybe.Nothing
        interfacePartialQueryDecoder
        GraphQL.Errors.decoder


type alias InterfacePartialResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InterfacePartialQuery


type alias InterfacePartialQuery =
    { animal : Animal
    }


interfacePartialQueryDecoder : Json.Decode.Decoder InterfacePartialQuery
interfacePartialQueryDecoder =
    Json.Decode.map InterfacePartialQuery
        (Json.Decode.field "animal" animalDecoder)


type Animal
    = OnDog Dog
    | OnOtherAnimal


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnDog dogDecoder
        , GraphQL.Helpers.Decode.emptyObject OnOtherAnimal
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
