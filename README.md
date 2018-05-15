# graphql-to-elm

[![Build Status](https://travis-ci.org/harmboschloo/graphql-to-elm.svg?branch=master)](https://travis-ci.org/harmboschloo/graphql-to-elm)

## == Work In Progress ==

`graphql-to-elm` validates graphql queries and converts them to elm code.

This package assumes that you use GraphQL [query documents](http://graphql.org/learn/queries/)
and a [schema document](http://graphql.org/learn/schema/) to write your queries and schema in.
Or that you have a way to generate these documents.

If you want to write your GraphQL queries in Elm have a look at
[dillonkearns/graphqelm](https://github.com/dillonkearns/graphqelm)
or [jamesmacaulay/elm-graphql](https://github.com/jamesmacaulay/elm-graphql).
For more options have a look at [this discussion](https://discourse.elm-lang.org/t/introducing-graphqelm-a-tool-for-type-safe-graphql-queries/472/4).

## Overview

For every query document `graphql-to-elm` will generate valid Elm **types**, **encoders** and **decoders** that you can use in your code.

It includes support for:

* operations (queries, mutations, subscriptions)
* operation names
* fragments
* inline fragments
* variables
* aliases
* directives
* custom scalar encoders and decoders
* custom enum encoders and decoders
* custom error decoder
* batched queries

### To do

* improve documentation
* generate union types from graphql enum types
* copy elm library files to destination folder

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
    And for every query file it will generate and elm file in the destination folder
    with Elm types, encoders and decoders.

4.  To use the generated files in your project you have to include the
    destination folder in the `source-directories` field of your `elm-package.json`.
    You'll also have to include the `node_modules/graphql-to-elm/elm` folder
    to include the `graphql-to-elm` [library](elm/GraphQL). It should look something like this:

    ```json
    "source-directories": [
        "src",
        "src-generated",
        "node_modules/graphql-to-elm/elm"
    ],
    ```

5.  Now you can import the `graphql-to-elm` [library files](elm/GraphQL) and generated
    Elm files in your project and use them.

    For full usage examples see the [examples folder](examples)
    or have a look at the [test fixtures folder](test/fixtures).

## Options

| option         | type                        | default                       | description                                                   |
| -------------- | --------------------------- | ----------------------------- | ------------------------------------------------------------- |
| schema         | `string`                    |                               | Filename of the schema document.                              |
| queries        | `string[]`                  |                               | Array of filenames of the query documents.                    |
| scalarEncoders | `TypeEncoders`              | `{}`                          | Scalar type encoders.                                         |
| enumEncoders   | `TypeEncoders`              | `{}`                          | Enum type encoders.                                           |
| scalarDecoders | `TypeDecoders`              | `{}`                          | Scalar type decoders.                                         |
| enumDecoders   | `TypeDecoders`              | `{}`                          | Enum type decoders.                                           |
| errorsDecoder  | `TypeDecoder`               | `GraphqlToElm.Errors` decoder | GraphQL response errors decoder                               |
| src            | `string`                    | `.`                           | Base folder of the queries.                                   |
| dest           | `string`                    | `src` option                  | Destination folder for the generateed elm files.              |
| operationKind  | `"query"` or `"named"`      | `"query"`                     | Send the full query to the server or only the operation name. |
| log            | `(message: string) => void` | `console.log`                 | Callback for log messages. Set to `null` to disable.          |

```TypeScript
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
