module InterfacePlain exposing
    ( Animal
    , InterfacePlainQuery
    , InterfacePlainResponse
    , interfacePlain
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


interfacePlain : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors InterfacePlainQuery
interfacePlain =
    GraphQL.Operation.withQuery
        """query InterfacePlain {
animal {
color
}
}"""
        Maybe.Nothing
        interfacePlainQueryDecoder
        GraphQL.Errors.decoder


type alias InterfacePlainResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors InterfacePlainQuery


type alias InterfacePlainQuery =
    { animal : Animal
    }


interfacePlainQueryDecoder : Json.Decode.Decoder InterfacePlainQuery
interfacePlainQueryDecoder =
    Json.Decode.map InterfacePlainQuery
        (Json.Decode.field "animal" animalDecoder)


type alias Animal =
    { color : String
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map Animal
        (Json.Decode.field "color" Json.Decode.string)
