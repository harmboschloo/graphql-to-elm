module Main exposing (main)

import Browser exposing (Document)
import GraphQL.Batch as Batch
import GraphQL.Enum.Language as Language
import GraphQL.Http
import GraphQL.Optional as Optional
import Html exposing (Html, button, dd, div, dl, dt, h1, h2, li, text, ul)
import Html.Events exposing (onClick)
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


init : () -> ( Model, Cmd Msg )
init _ =
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
                    , GraphQL.Http.send FieldsResponded (GraphQL.Http.postOperation Fields.query)
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
                    , GraphQL.Http.send AliasesResponded (GraphQL.Http.postOperation Aliases.query)
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
                    , GraphQL.Http.send FragmentsResponded (GraphQL.Http.postOperation Fragments.query)
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
                    , GraphQL.Http.send VariablesResponded
                        (GraphQL.Http.postOperation
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
                    , GraphQL.Http.send MutationsResponded
                        (GraphQL.Http.postOperation
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
                    , GraphQL.Http.sendBatch BatchResponded
                        (GraphQL.Http.postBatch
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


view : Model -> Document Msg
view model =
    { title = "features example - graphql-to-elm"
    , body =
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
    }


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

            Loaded loadedData ->
                viewData loadedData
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


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
