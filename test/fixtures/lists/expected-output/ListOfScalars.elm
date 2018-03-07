module ListOfScalars
    exposing
        ( Query
        , query
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
        """{
pets_pet
pets_petOrNull
petsOrNull_pet
petsOrNull_petOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


type alias Query =
    { pets_pet : List String
    , pets_petOrNull : List (Maybe.Maybe String)
    , petsOrNull_pet : Maybe.Maybe (List String)
    , petsOrNull_petOrNull : Maybe.Maybe (List (Maybe.Maybe String))
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map4 Query
        (Json.Decode.field "pets_pet" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "pets_petOrNull" (Json.Decode.list (Json.Decode.nullable Json.Decode.string)))
        (Json.Decode.field "petsOrNull_pet" (Json.Decode.nullable (Json.Decode.list Json.Decode.string)))
        (Json.Decode.field "petsOrNull_petOrNull" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable Json.Decode.string))))
