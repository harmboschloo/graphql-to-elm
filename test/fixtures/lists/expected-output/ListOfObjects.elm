module ListOfObjects
    exposing
        ( Query
        , Friend
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.query
        """{
friends_friend {
name
}
friends_friendOrNull {
name
}
friendsOrNull_friend {
name
}
friendsOrNull_friendOrNull {
name
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { friends_friend : List Friend
    , friends_friendOrNull : List (Maybe.Maybe Friend)
    , friendsOrNull_friend : Maybe.Maybe (List Friend)
    , friendsOrNull_friendOrNull : Maybe.Maybe (List (Maybe.Maybe Friend))
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map4 Query
        (Json.Decode.field "friends_friend" (Json.Decode.list friendDecoder))
        (Json.Decode.field "friends_friendOrNull" (Json.Decode.list (Json.Decode.nullable friendDecoder)))
        (Json.Decode.field "friendsOrNull_friend" (Json.Decode.nullable (Json.Decode.list friendDecoder)))
        (Json.Decode.field "friendsOrNull_friendOrNull" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable friendDecoder))))


type alias Friend =
    { name : Maybe.Maybe String
    }


friendDecoder : Json.Decode.Decoder Friend
friendDecoder =
    Json.Decode.map Friend
        (Json.Decode.field "name" (Json.Decode.nullable Json.Decode.string))
