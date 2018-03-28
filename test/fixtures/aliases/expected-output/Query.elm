module Query
    exposing
        ( AliasesQuery
        , User
        , User2
        , aliases
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


aliases : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors AliasesQuery
aliases =
    GraphqlToElm.Operation.withQuery
        """query Aliases {
user1: user {
id
email
}
user2: user {
id
name
}
user3: user {
id
email
}
user4: userOrNull {
id
name
}
user {
id
email
}
userOrNull {
id
name
}
}"""
        Maybe.Nothing
        aliasesQueryDecoder
        GraphqlToElm.Errors.decoder


type alias AliasesQuery =
    { user1 : User
    , user2 : User2
    , user3 : User
    , user4 : Maybe.Maybe User2
    , user : User
    , userOrNull : Maybe.Maybe User2
    }


aliasesQueryDecoder : Json.Decode.Decoder AliasesQuery
aliasesQueryDecoder =
    Json.Decode.map6 AliasesQuery
        (Json.Decode.field "user1" userDecoder)
        (Json.Decode.field "user2" user2Decoder)
        (Json.Decode.field "user3" userDecoder)
        (Json.Decode.field "user4" (Json.Decode.nullable user2Decoder))
        (Json.Decode.field "user" userDecoder)
        (Json.Decode.field "userOrNull" (Json.Decode.nullable user2Decoder))


type alias User =
    { id : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map2 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias User2 =
    { id : String
    , name : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map2 User2
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
