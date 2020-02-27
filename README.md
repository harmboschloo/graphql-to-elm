# graphql-to-elm

[![Build Status](https://travis-ci.org/harmboschloo/graphql-to-elm.svg?branch=master)](https://travis-ci.org/harmboschloo/graphql-to-elm)

`graphql-to-elm` validates GraphQL queries and converts them to Elm code.
Allowing you to use your queries and schema types in a type-safe way.

This package assumes that you use GraphQL [query documents](http://graphql.org/learn/queries/)
and a [schema document](http://graphql.org/learn/schema/) to write your queries and schema in.
Or that you have a way to generate these documents.

If you want to write your GraphQL queries in Elm have a look at
[dillonkearns/elm-graphql](https://github.com/dillonkearns/elm-graphql)
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

Then you create a code generation script (`prebuild.js` for instance) like this:

```js
const { graphqlToElm } = require("graphql-to-elm");

graphqlToElm({
  schema: "./src/mySchema.gql",
  queries: ["./src/myQuery.gql"],
  src: "./src",
  dest: "./src-generated"
}).catch(error => {
  console.error(error);
  process.exit(1);
});
```

You run the code generation script (`node prebuild.js`).

Then in your Elm code you can now do this
([full code here](https://github.com/harmboschloo/graphql-to-elm/tree/master/examples/readme/src/Main.elm)):

```elm
import GraphQL.Errors exposing (Errors)
import GraphQL.Response exposing (Response)
import MyQuery

init : () -> ( String, Cmd Msg )
init _ =
    ( "", postOperation MyQuery.userName GotUserName )

type Msg
    = GotUserName (Result Http.Error (Response Errors MyQuery.UserNameQuery))

update : Msg -> String -> ( String, Cmd Msg )
update msg _ =
    case msg of
        GotUserName (Ok (GraphQL.Response.Data data)) ->
            ( "user name: " ++ data.user.name, Cmd.none )

        GotUserName (Ok (GraphQL.Response.Errors _ _)) ->
            ( "GraphQL error", Cmd.none )

        GotUserName (Err _) ->
            ( "Http error", Cmd.none )
```

`graphql-to-elm` does not assume anything about how you send your GraphQL operations to your GraphQL server.
If you are using GraphQL over http you can define a function to post your operations like this:

```elm
import GraphQL.Errors exposing (Errors)
import GraphQL.Operation exposing (Operation)
import GraphQL.Response exposing (Response)

postOperation : Operation any Errors data -> (Result Http.Error (Response Errors data) -> msg) -> Cmd msg
postOperation operation msg =
    Http.post
        { url = "/graphql"
        , body = Http.jsonBody (GraphQL.Operation.encode operation)
        , expect = Http.expectJson msg (GraphQL.Response.decoder operation)
        }
```

## Setup

You'll need to have [node/npm](https://nodejs.org) installed.

1.  Install the generator node/npm package `graphql-to-elm` from the command line.  
    To add it to your project's `package.json` as a dev dependency use this command:

    ```shell
    npm install --save-dev graphql-to-elm
    ```

2.  Install the elm package `harmboschloo/graphql-to-elm` from the command line.  
    To add it to your project's `elm.json` use this command:

    ```shell
    elm install harmboschloo/graphql-to-elm
    ```

3.  Create a JavaScript file (for instance `prebuild.js`) similar to this one:

    ```js
    const { graphqlToElm } = require("graphql-to-elm");

    graphqlToElm({
      schema: "./src/schema.gql",
      queries: ["./src/MyQueries1.gql", "./src/MyQueries2.gql"],
      src: "./src",
      dest: "./src-generated"
    }).catch(error => {
      console.error(error);
      process.exit(1);
    });
    ```

4.  You can run this file from the command line with:

    ```shell
    node prebuild.js
    ```

    Running this command will read and validate your schema and queries.
    And for every query file it will generate and Elm file in the destination folder
    with Elm types, encoders and decoders.

5.  To use the generated files in your project you have to include the
    destination folder in the `source-directories` field of your `elm-package.json`.
    It should look something like this:

    ```json
    "source-directories": [
        "src",
        "src-generated"
    ],
    ```

6.  Now you can import the generated Elm files in your project and use them.

    For full usage examples see the [examples folder](https://github.com/harmboschloo/graphql-to-elm/tree/master/examples)
    or have a look at the [test fixtures folder](https://github.com/harmboschloo/graphql-to-elm/tree/master/tests/gen/fixtures).

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

## Options

### schema

```TypeScript
schema: string | { string: string }
```

Filename of the schema document. Or the whole schema as a string.

### enums

```TypeScript
enums?: { baseModule?: string} = {
  baseModule: "GraphQL.Enum"
}
```

Options for generating union types from GraphQL enums.
'baseModule' is the base module name for the union types.

### queries

```TypeScript
queries: string[]
```

Array of filenames of the query documents.

### src

```TypeScript
src?: string = "."
```

Base folder of the queries.

### dest

```TypeScript
dest?: string = "src"
```

Destination folder for the generateed Elm files.


### encoders

```TypeScript
interface TypeEncoders {
  [graphqlType: string]: TypeEncoder;
}

interface TypeEncoder {
  type: string;
  encoder: string;
}
```

### scalarEncoders

```TypeScript
scalarEncoders?: TypeEncoders = {}
```

Scalar type encoders.

### enumEncoders

```TypeScript
enumEncoders?: TypeEncoders = {}
```

Enum type encoders.


### decoders

```TypeScript
interface TypeDecoders {
  [graphqlType: string]: TypeDecoder;
}

interface TypeDecoder {
  type: string;
  decoder: string;
}
```

### scalarDecoders

```TypeScript
scalarDecoders?: TypeDecoders = {}
```

Scalar type decoders.

### enumDecoders

```TypeScript
enumDecoders?: TypeDecoders = {}
```

Enum type decoders.

### errorsDecoder

```TypeScript
errorsDecoder?: TypeDecoder = {
  type: "GraphQL.Errors.Errors",
  decoder: "GraphQL.Errors.decoder"
}
```

### operationKind

```TypeScript
operationKind?: "query" | "named" | "named_prefixed"
```

Send the full query to the server or only the operation name.
The operation name can be prefixed with the query filename: `[filename]:[operationName]`.

### log

```TypeScript
log?: (message: string) => void
```

Callback for log messages. Set to `null` to disable.
