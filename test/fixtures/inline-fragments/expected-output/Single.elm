module Single
    exposing
        ( Query
        , Animal
        , single
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


single : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
single =
    GraphqlToElm.Operation.query
        """query Single {
single: animal {
... on Animal {
color
size
}
}
shared: animal {
size
... on Animal {
color
}
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { single : Animal
    , shared : Animal
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map2 Query
        (Json.Decode.field "single" animalDecoder)
        (Json.Decode.field "shared" animalDecoder)


type alias Animal =
    { color : String
    , size : Float
    }


animalDecoder : Json.Decode.Decoder Animal
animalDecoder =
    Json.Decode.map2 Animal
        (Json.Decode.field "color" Json.Decode.string)
        (Json.Decode.field "size" Json.Decode.float)
