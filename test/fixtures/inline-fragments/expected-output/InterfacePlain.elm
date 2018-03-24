module InterfacePlain
    exposing
        ( Query
        , Animal
        , interfacePlain
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


interfacePlain : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
interfacePlain =
    GraphqlToElm.Operation.withQuery
        """query InterfacePlain {
animal {
color
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { animal : Animal
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "animal" animalDecoder)


type alias Animal =
    { color : String
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map Animal
        (Json.Decode.field "color" Json.Decode.string)
