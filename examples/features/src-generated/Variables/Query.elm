module Variables.Query
    exposing
        ( GetTranslationResponse
        , GetTranslationVariables
        , GetTranslationQuery
        , getTranslation
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Optional
import GraphqlToElm.Optional.Encode
import GraphqlToElm.Response
import Json.Decode
import Json.Encode
import Language


getTranslation : GetTranslationVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors GetTranslationQuery
getTranslation variables =
    GraphqlToElm.Operation.withQuery
        """query GetTranslation($id: ID!, $language: Language) {
translation(id: $id, language: $language)
}"""
        (Maybe.Just <| encodeGetTranslationVariables variables)
        getTranslationQueryDecoder
        GraphqlToElm.Errors.decoder


type alias GetTranslationResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors GetTranslationQuery


type alias GetTranslationVariables =
    { id : String
    , language : GraphqlToElm.Optional.Optional Language.Language
    }


encodeGetTranslationVariables : GetTranslationVariables -> Json.Encode.Value
encodeGetTranslationVariables inputs =
    GraphqlToElm.Optional.Encode.object
        [ ( "id", (Json.Encode.string >> GraphqlToElm.Optional.Present) inputs.id )
        , ( "language", (GraphqlToElm.Optional.map Language.encode) inputs.language )
        ]


type alias GetTranslationQuery =
    { translation : Maybe.Maybe String
    }


getTranslationQueryDecoder : Json.Decode.Decoder GetTranslationQuery
getTranslationQueryDecoder =
    Json.Decode.map GetTranslationQuery
        (Json.Decode.field "translation" (Json.Decode.nullable Json.Decode.string))
