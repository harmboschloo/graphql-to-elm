module InterfacePlain
    exposing
        ( InterfacePlainQuery
        , Animal
        , interfacePlain
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


interfacePlain : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors InterfacePlainQuery
interfacePlain =
    GraphqlToElm.Operation.withQuery
        """query InterfacePlain {
animal {
color
}
}"""
        Maybe.Nothing
        interfacePlainQueryDecoder
        GraphqlToElm.Errors.decoder


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
