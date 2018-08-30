module Queries exposing
    ( Group
    , Group2
    , Node(..)
    , Node2(..)
    , Node3(..)
    , NodeQuery
    , NodeResponse
    , NodeVariables
    , UnderscoresQuery
    , UnderscoresResponse
    , User
    , User2
    , User3
    , UserEmailQuery
    , UserEmailResponse
    , UserNameQuery
    , UserNameResponse
    , node
    , underscores
    , userEmail
    , userName
    )

import GraphQL.Errors
import GraphQL.Helpers.Decode
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


userName : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UserNameQuery
userName =
    GraphQL.Operation.withQuery
        """query UserName {
user {
name
}
}"""
        Maybe.Nothing
        userNameQueryDecoder
        GraphQL.Errors.decoder


userEmail : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UserEmailQuery
userEmail =
    GraphQL.Operation.withQuery
        """query UserEmail {
user {
email
}
}"""
        Maybe.Nothing
        userEmailQueryDecoder
        GraphQL.Errors.decoder


node : NodeVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors NodeQuery
node variables =
    GraphQL.Operation.withQuery
        """query Node($ID_UPPER: ID!, $id_lower: ID!, $id_lowerAndUpper: ID!) {
NODE_UPPER(ID_UPPER: $ID_UPPER) {
... on User {
name
}
}
node_lower(id_lower: $id_lower) {
... on User {
name
}
... on Group {
name
__typename
}
}
node_lowerAndUpper(id_lowerAndUpper: $id_lowerAndUpper) {
... on User {
id
email
}
... on Group {
id
}
}
}"""
        (Maybe.Just <| encodeNodeVariables variables)
        nodeQueryDecoder
        GraphQL.Errors.decoder


underscores : GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors UnderscoresQuery
underscores =
    GraphQL.Operation.withQuery
        """query Underscores {
_UNDERSCORE_UPPER
_underscore_lower
_underscore_lowerAndUpper
}"""
        Maybe.Nothing
        underscoresQueryDecoder
        GraphQL.Errors.decoder


type alias UserNameResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UserNameQuery


type alias UserEmailResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UserEmailQuery


type alias NodeResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors NodeQuery


type alias UnderscoresResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors UnderscoresQuery


type alias UserNameQuery =
    { user : User
    }


userNameQueryDecoder : Json.Decode.Decoder UserNameQuery
userNameQueryDecoder =
    Json.Decode.map UserNameQuery
        (Json.Decode.field "user" userDecoder)


type alias User =
    { name : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map User
        (Json.Decode.field "name" Json.Decode.string)


type alias UserEmailQuery =
    { user : User2
    }


userEmailQueryDecoder : Json.Decode.Decoder UserEmailQuery
userEmailQueryDecoder =
    Json.Decode.map UserEmailQuery
        (Json.Decode.field "user" user2Decoder)


type alias User2 =
    { email : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map User2
        (Json.Decode.field "email" Json.Decode.string)


type alias NodeVariables =
    { idUpper : String
    , id_lower : String
    , id_lowerAndUpper : String
    }


encodeNodeVariables : NodeVariables -> Json.Encode.Value
encodeNodeVariables inputs =
    Json.Encode.object
        [ ( "ID_UPPER", Json.Encode.string inputs.idUpper )
        , ( "id_lower", Json.Encode.string inputs.id_lower )
        , ( "id_lowerAndUpper", Json.Encode.string inputs.id_lowerAndUpper )
        ]


type alias NodeQuery =
    { nodeUpper : Maybe.Maybe Node
    , node_lower : Maybe.Maybe Node2
    , node_lowerAndUpper : Maybe.Maybe Node3
    }


nodeQueryDecoder : Json.Decode.Decoder NodeQuery
nodeQueryDecoder =
    Json.Decode.map3 NodeQuery
        (Json.Decode.field "NODE_UPPER" (Json.Decode.nullable nodeDecoder))
        (Json.Decode.field "node_lower" (Json.Decode.nullable node2Decoder))
        (Json.Decode.field "node_lowerAndUpper" (Json.Decode.nullable node3Decoder))


type Node
    = OnUser User
    | OnOtherNode


nodeDecoder : Json.Decode.Decoder Node
nodeDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnUser userDecoder
        , GraphQL.Helpers.Decode.emptyObject OnOtherNode
        ]


type Node2
    = OnGroup Group
    | OnUser2 User


node2Decoder : Json.Decode.Decoder Node2
node2Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnGroup groupDecoder
        , Json.Decode.map OnUser2 userDecoder
        ]


type alias Group =
    { name : String
    , typename__ : String
    }


groupDecoder : Json.Decode.Decoder Group
groupDecoder =
    Json.Decode.map2 Group
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "__typename" (GraphQL.Helpers.Decode.constant "Group" Json.Decode.string))


type Node3
    = OnUser3 User3
    | OnGroup2 Group2


node3Decoder : Json.Decode.Decoder Node3
node3Decoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnUser3 user3Decoder
        , Json.Decode.map OnGroup2 group2Decoder
        ]


type alias User3 =
    { id : String
    , email : String
    }


user3Decoder : Json.Decode.Decoder User3
user3Decoder =
    Json.Decode.map2 User3
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias Group2 =
    { id : String
    }


group2Decoder : Json.Decode.Decoder Group2
group2Decoder =
    Json.Decode.map Group2
        (Json.Decode.field "id" Json.Decode.string)


type alias UnderscoresQuery =
    { underscoreUpper_ : String
    , underscore_lower_ : String
    , underscore_lowerAndUpper_ : String
    }


underscoresQueryDecoder : Json.Decode.Decoder UnderscoresQuery
underscoresQueryDecoder =
    Json.Decode.map3 UnderscoresQuery
        (Json.Decode.field "_UNDERSCORE_UPPER" Json.Decode.string)
        (Json.Decode.field "_underscore_lower" Json.Decode.string)
        (Json.Decode.field "_underscore_lowerAndUpper" Json.Decode.string)
