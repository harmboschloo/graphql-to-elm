module Queries.Variables exposing
    ( TranslationQuery
    , TranslationResponse
    , TranslationVariables
    , encodeTranslationVariables
    , translation
    , translationVariablesDecoder
    )

import GraphQL.Enum.Language
import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


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
    , language : GraphQL.Optional.Optional GraphQL.Enum.Language.Language
    }


encodeTranslationVariables : TranslationVariables -> Json.Encode.Value
encodeTranslationVariables inputs =
    GraphQL.Optional.encodeObject
        [ ( "id", (Json.Encode.string >> GraphQL.Optional.Present) inputs.id )
        , ( "language", GraphQL.Optional.map GraphQL.Enum.Language.encode inputs.language )
        ]


translationVariablesDecoder : Json.Decode.Decoder TranslationVariables
translationVariablesDecoder =
    Json.Decode.map2 TranslationVariables
        (Json.Decode.field "id" Json.Decode.string)
        (GraphQL.Optional.fieldDecoder "language" GraphQL.Enum.Language.decoder)


type alias TranslationQuery =
    { translation : Maybe.Maybe String
    }


translationQueryDecoder : Json.Decode.Decoder TranslationQuery
translationQueryDecoder =
    Json.Decode.map TranslationQuery
        (Json.Decode.field "translation" (Json.Decode.nullable Json.Decode.string))
