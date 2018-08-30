module DefaultScalarTypes exposing
    ( Query
    , Response
    , query
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode


query : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors Query
query =
    GraphQL.Operation.withQuery
        """{
int
float
string
boolean
id
}"""
        Maybe.Nothing
        queryDecoder
        GraphQL.Errors.decoder


type alias Response =
    GraphQL.Response.Response GraphQL.Errors.Errors Query


type alias Query =
    { int : Int
    , float : Float
    , string : String
    , boolean : Bool
    , id : String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map5 Query
        (Json.Decode.field "int" Json.Decode.int)
        (Json.Decode.field "float" Json.Decode.float)
        (Json.Decode.field "string" Json.Decode.string)
        (Json.Decode.field "boolean" Json.Decode.bool)
        (Json.Decode.field "id" Json.Decode.string)
