module Main exposing (main)

import Html exposing (Html, div, h1, h2, dl, dt, dd, ul, li, button, text)
import Html.Events exposing (onClick)
import GraphQL
    exposing
        ( Response
        , send
        , sendBatch
        , postQuery
        , postMutation
        , postBatch
        )
import GraphqlToElm.Batch as Batch
import GraphqlToElm.Optional as Optional
import Language
import Queries.Aliases as Aliases
import Queries.Fields as Fields
import Queries.Fragments as Fragments
import Queries.Mutations as Mutations
import Queries.Variables as Variables


-- Helpers


type Data a
    = None
    | Loading
    | LoadError String
    | Loaded a


toData : Result String a -> Data a
toData result =
    case result of
        Err error ->
            LoadError error

        Ok data ->
            Loaded data



-- Model


type alias BatchData =
    { aliases : Aliases.Query
    , mutations : Mutations.PostMessageMutation
    }


type alias Model =
    { fields : Data Fields.Query
    , aliases : Data Aliases.Query
    , fragments : Data Fragments.Query
    , variables : Data Variables.TranslationQuery
    , mutations : Data Mutations.PostMessageMutation
    , batch : Data BatchData
    }


init : ( Model, Cmd Msg )
init =
    ( Model None None None None None None
    , Cmd.none
    )



-- Update


type Msg
    = FieldsRequested
    | FieldsResponded (Result String Fields.Query)
    | AliasesRequested
    | AliasesResponded (Result String Aliases.Query)
    | FragmentsRequested
    | FragmentsResponded (Result String Fragments.Query)
    | VariablesRequested
    | VariablesResponded (Result String Variables.TranslationQuery)
    | MutationsRequested
    | MutationsResponded (Result String Mutations.PostMessageMutation)
    | BatchRequested
    | BatchResponded (Result String BatchData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FieldsRequested ->
            case model.fields of
                None ->
                    ( { model | fields = Loading }
                    , send FieldsResponded (postQuery Fields.query)
                    )

                _ ->
                    ( model, Cmd.none )

        FieldsResponded result ->
            case model.fields of
                Loading ->
                    ( { model | fields = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AliasesRequested ->
            case model.aliases of
                None ->
                    ( { model | aliases = Loading }
                    , send AliasesResponded (postQuery Aliases.query)
                    )

                _ ->
                    ( model, Cmd.none )

        AliasesResponded result ->
            case model.aliases of
                Loading ->
                    ( { model | aliases = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        FragmentsRequested ->
            case model.fragments of
                None ->
                    ( { model | fragments = Loading }
                    , send FragmentsResponded (postQuery Fragments.query)
                    )

                _ ->
                    ( model, Cmd.none )

        FragmentsResponded result ->
            case model.fragments of
                Loading ->
                    ( { model | fragments = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        VariablesRequested ->
            case model.variables of
                None ->
                    ( { model | variables = Loading }
                    , send VariablesResponded
                        (postQuery
                            (Variables.translation
                                { id = "hello.world"
                                , language = Optional.Present Language.En
                                }
                            )
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        VariablesResponded result ->
            case model.variables of
                Loading ->
                    ( { model | variables = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        MutationsRequested ->
            case model.mutations of
                None ->
                    ( { model | mutations = Loading }
                    , send MutationsResponded
                        (postMutation
                            (Mutations.postMessage { message = "Hello" })
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        MutationsResponded result ->
            case model.mutations of
                Loading ->
                    ( { model | mutations = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        BatchRequested ->
            case model.batch of
                None ->
                    ( { model | batch = Loading }
                    , sendBatch BatchResponded
                        (postBatch
                            (Batch.batch BatchData
                                |> Batch.query Aliases.query
                                |> Batch.mutation
                                    (Mutations.postMessage
                                        { message = "Hello Batch" }
                                    )
                            )
                        )
                    )

                _ ->
                    ( model, Cmd.none )

        BatchResponded result ->
            case model.batch of
                Loading ->
                    ( { model | batch = toData result }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "graphql-to-elm features example" ]
        , viewFeature "Fields"
            FieldsRequested
            model.fields
            viewFields
        , viewFeature "Aliases"
            AliasesRequested
            model.aliases
            viewAliases
        , viewFeature "Fragments"
            FragmentsRequested
            model.fragments
            viewFragments
        , viewFeature "Variables"
            VariablesRequested
            model.variables
            viewVariables
        , viewFeature "Mutations"
            MutationsRequested
            model.mutations
            viewMutations
        , viewFeature "Batch"
            BatchRequested
            model.batch
            viewBatch
        ]


viewFeature : String -> Msg -> Data a -> (a -> Html Msg) -> Html Msg
viewFeature label loadMsg data viewData =
    div []
        [ h2 [] [ text label ]
        , case data of
            None ->
                button [ onClick loadMsg ] [ text "load" ]

            Loading ->
                text "..."

            LoadError error ->
                text ("Error: " ++ error)

            Loaded data ->
                viewData data
        ]



-- fields


viewFields : Fields.Query -> Html Msg
viewFields data =
    dl []
        [ dt [] [ text "user" ]
        , dd [] [ viewFieldsUser data.user ]
        , dt [] [ text "lastMessage" ]
        , dd []
            [ data.lastMessage
                |> Maybe.map viewFieldsMessage
                |> Maybe.withDefault (text "Nothing")
            ]
        , dt [] [ text "messages" ]
        , dd [] [ viewFieldsMessages data.messages ]
        ]


viewFieldsUser : Fields.User -> Html Msg
viewFieldsUser user =
    dl []
        [ dt [] [ text "User" ]
        , dd []
            [ dl []
                [ dt [] [ text "name" ]
                , dd [] [ text user.name ]
                , dt [] [ text "email" ]
                , dd [] [ text user.email ]
                ]
            ]
        ]


viewFieldsMessages : List Fields.Message -> Html Msg
viewFieldsMessages messages =
    dl []
        [ dt [] [ text "List Message" ]
        , dd []
            [ ul []
                (List.map
                    (\message -> li [] [ viewFieldsMessage message ])
                    messages
                )
            ]
        ]


viewFieldsMessage : Fields.Message -> Html Msg
viewFieldsMessage message =
    dl []
        [ dt [] [ text "Message" ]
        , dd []
            [ dl []
                [ dt [] [ text "message" ]
                , dd [] [ text message.message ]
                ]
            ]
        ]



-- aliases


viewAliases : Aliases.Query -> Html Msg
viewAliases data =
    dl []
        [ dt [] [ text "translation \"hello.world\" EN" ]
        , dd [] [ text (data.en |> Maybe.withDefault "Nothing") ]
        , dt [] [ text "translation \"hello.world\" NL" ]
        , dd [] [ text (data.nl |> Maybe.withDefault "Nothing") ]
        ]



-- fragments


viewFragments : Fragments.Query -> Html Msg
viewFragments data =
    dl []
        [ dt [] [ text "user" ]
        , dd [] [ viewFragmentsUser data.user ]
        , dt [] [ text "lastMessage" ]
        , dd []
            [ data.lastMessage
                |> Maybe.map viewFragmentsMessage
                |> Maybe.withDefault (text "Nothing")
            ]
        , dt [] [ text "messages" ]
        , dd [] [ viewFragementsMessages data.messages ]
        ]


viewFragmentsUser : Fragments.User -> Html Msg
viewFragmentsUser user =
    dl []
        [ dt [] [ text "User" ]
        , dd []
            [ dl []
                [ dt [] [ text "id" ]
                , dd [] [ text user.id ]
                , dt [] [ text "name" ]
                , dd [] [ text user.name ]
                , dt [] [ text "email" ]
                , dd [] [ text user.email ]
                ]
            ]
        ]


viewFragementsMessages : List Fragments.Message -> Html Msg
viewFragementsMessages messages =
    dl []
        [ dt [] [ text "List Message" ]
        , dd []
            [ ul []
                (List.map
                    (\message -> li [] [ viewFragmentsMessage message ])
                    messages
                )
            ]
        ]


viewFragmentsMessage : Fragments.Message -> Html Msg
viewFragmentsMessage message =
    dl []
        [ dt [] [ text "Message" ]
        , dd []
            [ dl []
                [ dt [] [ text "id" ]
                , dd [] [ text message.id ]
                , dt [] [ text "message" ]
                , dd [] [ text message.message ]
                , dt [] [ text "from" ]
                , dd [] [ viewFragmentsUser message.from ]
                ]
            ]
        ]



-- variables


viewVariables : Variables.TranslationQuery -> Html Msg
viewVariables data =
    dl []
        [ dt [] [ text "Translation" ]
        , dd [] [ text (Maybe.withDefault "Nothing" data.translation) ]
        ]



-- mutations


viewMutations : Mutations.PostMessageMutation -> Html Msg
viewMutations data =
    dl []
        [ dt [] [ text "Message ID" ]
        , dd [] [ text (Maybe.withDefault "Nothing" data.postMessage) ]
        ]



-- batch


viewBatch : BatchData -> Html Msg
viewBatch data =
    dl []
        [ dt [] [ text "Aliases" ]
        , dd [] [ viewAliases data.aliases ]
        , dt [] [ text "Mutations" ]
        , dd [] [ viewMutations data.mutations ]
        ]



-- Main


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
