module Big
    exposing
        ( Response
        , Query
        , Person
        , Intel
        , query
        )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
i {
intel {
field1
field2
field3
field4
field5
field6
field7
field8
field9
field10
field11
field12
}
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { i : Person
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "i" personDecoder)


type alias Person =
    { intel : Maybe.Maybe Intel
    }


personDecoder : Json.Decode.Decoder Person
personDecoder =
    Json.Decode.map Person
        (Json.Decode.field "intel" (Json.Decode.nullable intelDecoder))


type alias Intel =
    { field1 : Int
    , field2 : String
    , field3 : Float
    , field4 : List Int
    , field5 : List String
    , field6 : List Float
    , field7 : Int
    , field8 : String
    , field9 : Float
    , field10 : List Int
    , field11 : List String
    , field12 : List Float
    }


intelDecoder : Json.Decode.Decoder Intel
intelDecoder =
    Json.Decode.map8 Intel
        (Json.Decode.field "field1" Json.Decode.int)
        (Json.Decode.field "field2" Json.Decode.string)
        (Json.Decode.field "field3" Json.Decode.float)
        (Json.Decode.field "field4" (Json.Decode.list Json.Decode.int))
        (Json.Decode.field "field5" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "field6" (Json.Decode.list Json.Decode.float))
        (Json.Decode.field "field7" Json.Decode.int)
        (Json.Decode.field "field8" Json.Decode.string)
        |> GraphQL.Helpers.Decode.andMap (Json.Decode.field "field9" Json.Decode.float)
        |> GraphQL.Helpers.Decode.andMap (Json.Decode.field "field10" (Json.Decode.list Json.Decode.int))
        |> GraphQL.Helpers.Decode.andMap (Json.Decode.field "field11" (Json.Decode.list Json.Decode.string))
        |> GraphQL.Helpers.Decode.andMap (Json.Decode.field "field12" (Json.Decode.list Json.Decode.float))
