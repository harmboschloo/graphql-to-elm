# graphql-to-elm

[![Build Status](https://travis-ci.org/harmboschloo/graphql-to-elm.svg?branch=master)](https://travis-ci.org/harmboschloo/graphql-to-elm)

`graphql-to-elm` validates GraphQL queries and converts them to Elm code. Can be used with [elm 0.19](https://www.npmjs.com/package/elm) and [graphql 0.12, 0.13 and 14](https://www.npmjs.com/package/graphql).

This package assumes that you use GraphQL [query documents](http://graphql.org/learn/queries/)
and a [schema document](http://graphql.org/learn/schema/) to write your queries and schema in.
Or that you have a way to generate these documents.

If you want to write your GraphQL queries in Elm have a look at
[dillonkearns/graphqelm](https://github.com/dillonkearns/graphqelm)
or [jamesmacaulay/elm-graphql](https://github.com/jamesmacaulay/elm-graphql).
For more options have a look at [this discussion](https://discourse.elm-lang.org/t/introducing-graphqelm-a-tool-for-type-safe-graphql-queries/472/4).

## How does it work

Suppose you have a GraphQL query file (`myQuery.gql`):

```gql
query UserName {
  user {
    name
  }
}
```

Then you create a code generation script (`prebuild.js`) like this:

```js
const { graphqlToElm } = require("graphql-to-elm");

graphqlToElm({
  schema: "./src/mySchema.gql",
  queries: ["./src/myQuery.gql"],
  src: "./src",
  dest: "./src-generated"
});
```

You run the code generation script (`node prebuild.js`).

Then in your Elm code you can do this ([full code](examples/readme/src/Main.elm) and [`GraphQL` package](https://package.elm-lang.org/packages/harmboschloo/graphql-to-elm-package/latest/)):

```elm
import GraphQL.Errors exposing (Errors)
import GraphQL.Http.Basic exposing (postQuery)
import GraphQL.Response as Response exposing (Response)
import Http
import MyQuery

init : () -> ( String, Cmd Msg )
init _ =
    ( "", Http.send GotUserName (postQuery "/graphql" MyQuery.userName) )

type Msg
    = GotUserName (Result Http.Error (Response Errors MyQuery.UserNameQuery))

update : Msg -> String -> ( String, Cmd Msg )
update msg model =
    case msg of
        GotUserName (Ok (Response.Data data)) ->
            ( "user name: " ++ data.user.name, Cmd.none )

        GotUserName (Ok (Response.Errors _ _)) ->
            ( "GraphQL error", Cmd.none )

        GotUserName (Err _) ->
            ( "Http error", Cmd.none )
```

## Overview

For every query document `graphql-to-elm` will generate valid Elm **types**, **encoders** and **decoders** that you can use in your code.

It includes support for:

- operations (queries, mutations, subscriptions)
- operation names
- fragments
- inline fragments
- variables
- aliases
- directives
- enums
- custom scalar encoders and decoders
- custom enum encoders and decoders
- custom error decoder
- batched queries

## Usage

You'll need to have [node/npm](https://nodejs.org) installed.

1.  Install `graphql-to-elm` from the command line through npm.  
    To add it to your project's `package.json` as a dev dependency use this command:

    ```shell
    npm install --save-dev graphql-to-elm
    ```

2.  Create a JavaScript file (for instance `prebuild.js`) similar to this one:

    ```js
    const { graphqlToElm } = require("graphql-to-elm");

    graphqlToElm({
      schema: "./src/schema.gql",
      queries: ["./src/MyQueries1.gql", "./src/MyQueries2.gql"],
      src: "./src",
      dest: "./src-generated"
    });
    ```

3.  You can run this file from the command line with:

    ```shell
    node prebuild.js
    ```

    Running this command will read and validate your schema and queries.
    And for every query file it will generate and Elm file in the destination folder
    with Elm types, encoders and decoders.

4.  To use the generated files in your project you have to include the
    destination folder in the `source-directories` field of your `elm-package.json`.
    It should look something like this:

    ```json
    "source-directories": [
        "src",
        "src-generated"
    ],
    ```

5.  Now you can import the generated Elm files
    (which include the [`graphql-to-elm` package](https://package.elm-lang.org/packages/harmboschloo/graphql-to-elm-package/latest/) files)
    in your project and use them.

    For full usage examples see the [examples folder](examples)
    or have a look at the [test fixtures folder](test/fixtures).

## Options

| option         | type                                       | default                          | description                                                                                                                                             |
| -------------- | ------------------------------------------ | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| schema         | `string | { string: string }`              |                                  | Filename of the schema document. Or the whole schema as a string.                                                                                       |
| enums          | `EnumOptions`                              | `{ baseModule: "GraphQL.Enum" }` | Options for generating union types from GraphQL enums. 'baseModule' is the base module name for the union types.                                        |
| queries        | `string[]`                                 |                                  | Array of filenames of the query documents.                                                                                                              |
| scalarEncoders | `TypeEncoders`                             | `{}`                             | Scalar type encoders.                                                                                                                                   |
| enumEncoders   | `TypeEncoders`                             | `{}`                             | Enum type encoders.                                                                                                                                     |
| scalarDecoders | `TypeDecoders`                             | `{}`                             | Scalar type decoders.                                                                                                                                   |
| enumDecoders   | `TypeDecoders`                             | `{}`                             | Enum type decoders.                                                                                                                                     |
| errorsDecoder  | `TypeDecoder`                              | `GraphQL.Errors` decoder         | GraphQL response errors decoder                                                                                                                         |
| src            | `string`                                   | `.`                              | Base folder of the queries.                                                                                                                             |
| dest           | `string`                                   | `src` option                     | Destination folder for the generateed Elm files.                                                                                                        |
| operationKind  | `"query"`, `"named"` or `"named_prefixed"` | `"query"`                        | Send the full query to the server or only the operation name. The operation name can be prefixed with the query filename: `[filename]:[operationName]`. |
| log            | `(message: string) => void`                | `console.log`                    | Callback for log messages. Set to `null` to disable.                                                                                                    |

```TypeScript
interface EnumOptions {
  baseModule?: string;
}

interface TypeEncoders {
  [graphqlType: string]: TypeEncoder;
}

interface TypeEncoder {
  type: string;
  encoder: string;
}

interface TypeDecoders {
  [graphqlType: string]: TypeDecoder;
}

interface TypeDecoder {
  type: string;
  decoder: string;
}
```
