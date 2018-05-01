# graphql-to-elm

[![Build Status](https://travis-ci.org/harmboschloo/graphql-to-elm.svg?branch=master)](https://travis-ci.org/harmboschloo/graphql-to-elm)

**This package is Work In Progress**

`graphql-to-elm` validates graphql queries and converts them to elm code.

This package assumes that you use GraphQL [query documents](http://graphql.org/learn/queries/) and a [schema document](http://graphql.org/learn/schema/) to write your queries and schema in. Or that you have a way to generate these documents.

If you want to write your GraphQL queries in Elm have a look at [dillonkearns/graphqelm](https://github.com/dillonkearns/graphqelm)
or [jamesmacaulay/elm-graphql](https://github.com/jamesmacaulay/elm-graphql).

## Overview

For every query document `graphql-to-elm` will generate valid Elm **types**, **encoders** and **decoders** that you can use in your code.

It includes support for:

* queries
* mutations
* subscriptions
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

## Usage

TODO

See the [examples folder](examples) or [test fixtures folder](test/fixtures) for more elaborate examples.

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
