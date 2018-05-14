module Queries.Variables
    exposing
        ( TranslationResponse
        , TranslationVariables
        , TranslationQuery
        , translation
        )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode
import Language


translation : TranslationVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors TranslationQuery
translation variables =
    GraphQL.Operation.withQuery
        """query Translation($id: ID!, $language: Language) {
translation(id: $id, language: $language)
}"""
        (Maybe.Just <| encodeTranslationVariables variables)
        translationQueryDecoder
        GraphQL.Errors.decoder


type alias TranslationResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors TranslationQuery


type alias TranslationVariables =
    { id : String
    , language : GraphQL.Optional.Optional Language.Language
    }


encodeTranslationVariables : TranslationVariables -> Json.Encode.Value
encodeTranslationVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "id", (Json.Encode.string >> GraphQL.Optional.Present) inputs.id )
        , ( "language", (GraphQL.Optional.map Language.encode) inputs.language )
        ]


type alias TranslationQuery =
    { translation : Maybe.Maybe String
    }


translationQueryDecoder : Json.Decode.Decoder TranslationQuery
translationQueryDecoder =
    Json.Decode.map TranslationQuery
        (Json.Decode.field "translation" (Json.Decode.nullable Json.Decode.string))
