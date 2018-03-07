module DefaultScalarTypes
    exposing
        ( Query
        , query
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode


query : GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
query =
    GraphqlToElm.Graphql.Operation.query
        """{
int
float
string
boolean
id
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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
