module Queries.Variables
    exposing
        ( TranslationResponse
        , TranslationVariables
        , TranslationQuery
        , translation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import GraphqlToElm.Response
import Json.Decode
import Json.Encode
import Language


translation : TranslationVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors TranslationQuery
translation variables =
    GraphqlToElm.Operation.withQuery
        """query Translation($id: ID!, $language: Language) {
translation(id: $id, language: $language)
}"""
        (Maybe.Just <| encodeTranslationVariables variables)
        translationQueryDecoder
        GraphqlToElm.Errors.decoder


type alias TranslationResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors TranslationQuery


type alias TranslationVariables =
    { id : String
    , language : GraphqlToElm.Optional.Optional Language.Language
    }


encodeTranslationVariables : TranslationVariables -> Json.Encode.Value
encodeTranslationVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "id", (Json.Encode.string >> GraphqlToElm.Optional.Present) inputs.id )
        , ( "language", (GraphqlToElm.Optional.map Language.encode) inputs.language )
        ]


type alias TranslationQuery =
    { translation : Maybe.Maybe String
    }


translationQueryDecoder : Json.Decode.Decoder TranslationQuery
translationQueryDecoder =
    Json.Decode.map TranslationQuery
        (Json.Decode.field "translation" (Json.Decode.nullable Json.Decode.string))
