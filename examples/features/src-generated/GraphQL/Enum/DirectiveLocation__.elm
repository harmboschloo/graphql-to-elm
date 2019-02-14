module GraphQL.Enum.DirectiveLocation__ exposing
    ( DirectiveLocation__(..)
    , decoder
    , encode
    , fromString
    , toString
    )

import Json.Decode
import Json.Encode


type DirectiveLocation__
    = Query
    | Mutation
    | Subscription
    | Field
    | FragmentDefinition
    | FragmentSpread
    | InlineFragment
    | VariableDefinition
    | Schema
    | Scalar
    | Object
    | FieldDefinition
    | ArgumentDefinition
    | Interface
    | Union
    | Enum
    | EnumValue
    | InputObject
    | InputFieldDefinition


encode : DirectiveLocation__ -> Json.Encode.Value
encode value =
    Json.Encode.string (toString value)


decoder : Json.Decode.Decoder DirectiveLocation__
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\value ->
                value
                    |> fromString
                    |> Maybe.map Json.Decode.succeed
                    |> Maybe.withDefault
                        (Json.Decode.fail <| "unknown DirectiveLocation__ " ++ value)
            )


toString : DirectiveLocation__ -> String
toString value =
    case value of
        Query ->
            "QUERY"

        Mutation ->
            "MUTATION"

        Subscription ->
            "SUBSCRIPTION"

        Field ->
            "FIELD"

        FragmentDefinition ->
            "FRAGMENT_DEFINITION"

        FragmentSpread ->
            "FRAGMENT_SPREAD"

        InlineFragment ->
            "INLINE_FRAGMENT"

        VariableDefinition ->
            "VARIABLE_DEFINITION"

        Schema ->
            "SCHEMA"

        Scalar ->
            "SCALAR"

        Object ->
            "OBJECT"

        FieldDefinition ->
            "FIELD_DEFINITION"

        ArgumentDefinition ->
            "ARGUMENT_DEFINITION"

        Interface ->
            "INTERFACE"

        Union ->
            "UNION"

        Enum ->
            "ENUM"

        EnumValue ->
            "ENUM_VALUE"

        InputObject ->
            "INPUT_OBJECT"

        InputFieldDefinition ->
            "INPUT_FIELD_DEFINITION"


fromString : String -> Maybe DirectiveLocation__
fromString value =
    case value of
        "QUERY" ->
            Just Query

        "MUTATION" ->
            Just Mutation

        "SUBSCRIPTION" ->
            Just Subscription

        "FIELD" ->
            Just Field

        "FRAGMENT_DEFINITION" ->
            Just FragmentDefinition

        "FRAGMENT_SPREAD" ->
            Just FragmentSpread

        "INLINE_FRAGMENT" ->
            Just InlineFragment

        "VARIABLE_DEFINITION" ->
            Just VariableDefinition

        "SCHEMA" ->
            Just Schema

        "SCALAR" ->
            Just Scalar

        "OBJECT" ->
            Just Object

        "FIELD_DEFINITION" ->
            Just FieldDefinition

        "ARGUMENT_DEFINITION" ->
            Just ArgumentDefinition

        "INTERFACE" ->
            Just Interface

        "UNION" ->
            Just Union

        "ENUM" ->
            Just Enum

        "ENUM_VALUE" ->
            Just EnumValue

        "INPUT_OBJECT" ->
            Just InputObject

        "INPUT_FIELD_DEFINITION" ->
            Just InputFieldDefinition

        _ ->
            Nothing
