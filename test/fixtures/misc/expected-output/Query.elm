module Query
    exposing
        ( TestQueryResponse
        , TestQueryQuery
        , User
        , User2
        , User4
        , User3
        , User5
        , testQuery
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import GraphqlToElm.Response
import Json.Decode


testQuery : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors TestQueryQuery
testQuery =
    GraphqlToElm.Operation.withQuery
        """query TestQuery {
i {
name
}
version
me {
name
age
}
you {
name
friends {
id
age
}
relatives {
name
}
}
them {
age
name
}
maybeThem {
age
}
}"""
        Maybe.Nothing
        testQueryQueryDecoder
        GraphqlToElm.Errors.decoder


type alias TestQueryResponse =
    GraphqlToElm.Response.Response GraphqlToElm.Errors.Errors TestQueryQuery


type alias TestQueryQuery =
    { i : User
    , version : Int
    , me : User2
    , you : Maybe.Maybe User4
    , them : List User2
    , maybeThem : Maybe.Maybe (List (Maybe.Maybe User5))
    }


testQueryQueryDecoder : Json.Decode.Decoder TestQueryQuery
testQueryQueryDecoder =
    Json.Decode.map6 TestQueryQuery
        (Json.Decode.field "i" userDecoder)
        (Json.Decode.field "version" Json.Decode.int)
        (Json.Decode.field "me" user2Decoder)
        (Json.Decode.field "you" (Json.Decode.nullable user4Decoder))
        (Json.Decode.field "them" (Json.Decode.list user2Decoder))
        (Json.Decode.field "maybeThem" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable user5Decoder))))


type alias User =
    { name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map User
        (Json.Decode.field "name" Json.Decode.string)


type alias User2 =
    { name : String
    , age : Maybe.Maybe Int
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map2 User2
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User4 =
    { name : String
    , friends : Maybe.Maybe (List User3)
    , relatives : List User
    }


user4Decoder : Json.Decode.Decoder User4
user4Decoder =
    Json.Decode.map3 User4
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "friends" (Json.Decode.nullable (Json.Decode.list user3Decoder)))
        (Json.Decode.field "relatives" (Json.Decode.list userDecoder))


type alias User3 =
    { id : String
    , age : Maybe.Maybe Int
    }


user3Decoder : Json.Decode.Decoder User3
user3Decoder =
    Json.Decode.map2 User3
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))


type alias User5 =
    { age : Maybe.Maybe Int
    }


user5Decoder : Json.Decode.Decoder User5
user5Decoder =
    Json.Decode.map User5
        (Json.Decode.field "age" (Json.Decode.nullable Json.Decode.int))
