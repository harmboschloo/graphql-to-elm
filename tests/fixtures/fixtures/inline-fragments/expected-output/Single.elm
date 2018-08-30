module Single exposing
    ( Animal
    , SingleQuery
    , SingleResponse
    , single
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


single : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors SingleQuery
single =
    GraphQL.Operation.withQuery
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
        GraphQL.Errors.decoder


type alias SingleResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors SingleQuery


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
