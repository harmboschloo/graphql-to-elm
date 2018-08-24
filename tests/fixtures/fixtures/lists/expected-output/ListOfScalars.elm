module ListOfScalars
    exposing
        ( Response
        , Query
        , query
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
pets_pet
pets_petOrNull
petsOrNull_pet
petsOrNull_petOrNull
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


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
