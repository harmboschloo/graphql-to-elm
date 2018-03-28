module Single
    exposing
        ( SingleQuery
        , Animal
        , single
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


single : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors SingleQuery
single =
    GraphqlToElm.Operation.withQuery
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
        singleQueryDecoder
        GraphqlToElm.Errors.decoder


type alias SingleQuery =
    { single : Animal
    , shared : Animal
    }


singleQueryDecoder : Json.Decode.Decoder SingleQuery
singleQueryDecoder =
    Json.Decode.map2 SingleQuery
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
