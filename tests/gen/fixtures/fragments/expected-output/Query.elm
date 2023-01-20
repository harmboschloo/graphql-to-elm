module Query exposing
    ( Flip(..)
    , FragmentsQuery
    , FragmentsResponse
    , FragmentsVariables
    , Heads
    , Profile
    , Tails
    , User
    , User2
    , fragments
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Response
import Json.Decode
import Json.Encode


fragments : FragmentsVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors FragmentsQuery
fragments variables =
    GraphQL.Operation.withQuery
        ("""query Fragments($id: String!) {
user1: user {
...fields
}
user2: user {
...fields
}
user3: userOrNull {
...fields
}
user4: userById(id: $id) {
...fields
}
user5: user {
email
...userId
...userName
...userAndProfile
...userProfile
profile {
...profileName
}
}
flip {
...heads
... on Tails {
length
}
}
}"""
            ++ fields
            ++ userId
            ++ userName
            ++ userAndProfile
            ++ profileImage
            ++ userProfile
            ++ profileId
            ++ profileName
            ++ heads
        )
        (Maybe.Just <| encodeFragmentsVariables variables)
        fragmentsQueryDecoder
        GraphQL.Errors.decoder


fields : String
fields =
    """fragment fields on User {
id
name
email
}"""


userId : String
userId =
    """fragment userId on User {
id
}"""


userName : String
userName =
    """fragment userName on User {
name
}"""


userAndProfile : String
userAndProfile =
    """fragment userAndProfile on User {
name
email
profile {
...profileImage
}
}"""


userProfile : String
userProfile =
    """fragment userProfile on User {
profile {
...profileId
name
image
}
}"""


profileId : String
profileId =
    """fragment profileId on Profile {
id
}"""


profileName : String
profileName =
    """fragment profileName on Profile {
name
}"""


profileImage : String
profileImage =
    """fragment profileImage on Profile {
image
}"""


heads : String
heads =
    """fragment heads on Heads {
name
}"""


type alias FragmentsResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors FragmentsQuery


type alias FragmentsVariables =
    { id : String
    }


encodeFragmentsVariables : FragmentsVariables -> Json.Encode.Value
encodeFragmentsVariables inputs =
    Json.Encode.object
        [ ( "id", Json.Encode.string inputs.id )
        ]


type alias FragmentsQuery =
    { user1 : User
    , user2 : User
    , user3 : Maybe.Maybe User
    , user4 : Maybe.Maybe User
    , user5 : User2
    , flip : Flip
    }


fragmentsQueryDecoder : Json.Decode.Decoder FragmentsQuery
fragmentsQueryDecoder =
    Json.Decode.map6 FragmentsQuery
        (Json.Decode.field "user1" userDecoder)
        (Json.Decode.field "user2" userDecoder)
        (Json.Decode.field "user3" (Json.Decode.nullable userDecoder))
        (Json.Decode.field "user4" (Json.Decode.nullable userDecoder))
        (Json.Decode.field "user5" user2Decoder)
        (Json.Decode.field "flip" flipDecoder)


type alias User =
    { id : String
    , name : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


type alias User2 =
    { email : String
    , profile : Maybe.Maybe Profile
    , id : String
    , name : String
    }


user2Decoder : Json.Decode.Decoder User2
user2Decoder =
    Json.Decode.map4 User2
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.field "profile" (Json.Decode.nullable profileDecoder))
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)


type alias Profile =
    { name : String
    , image : Maybe.Maybe String
    , id : String
    }


profileDecoder : Json.Decode.Decoder Profile
profileDecoder =
    Json.Decode.map3 Profile
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "image" (Json.Decode.nullable Json.Decode.string))
        (Json.Decode.field "id" Json.Decode.string)


type Flip
    = OnHeads Heads
    | OnTails Tails


flipDecoder : Json.Decode.Decoder Flip
flipDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map OnHeads headsDecoder
        , Json.Decode.map OnTails tailsDecoder
        ]


type alias Heads =
    { name : String
    }


headsDecoder : Json.Decode.Decoder Heads
headsDecoder =
    Json.Decode.map Heads
        (Json.Decode.field "name" Json.Decode.string)


type alias Tails =
    { length : Float
    }


tailsDecoder : Json.Decode.Decoder Tails
tailsDecoder =
    Json.Decode.map Tails
        (Json.Decode.field "length" Json.Decode.float)
