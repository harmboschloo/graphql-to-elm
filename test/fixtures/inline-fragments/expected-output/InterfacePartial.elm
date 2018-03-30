module InterfacePartial
    exposing
        ( InterfacePartialResponse
        , InterfacePartialQuery
        , Animal(..)
        , Dog
        , interfacePartial
        )

import GraphqlToElm.Errors
import GraphqlToElm.Helpers.Decode
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


interfacePartial : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InterfacePartialQuery
interfacePartial =
    GraphqlToElm.Operation.withQuery
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
        GraphqlToElm.Errors.decoder


type alias InterfacePartialResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors InterfacePartialQuery


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
        , GraphqlToElm.Helpers.Decode.emptyObject OnOtherAnimal
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
