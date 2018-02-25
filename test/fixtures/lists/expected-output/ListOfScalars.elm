module ListOfScalars
    exposing
        ( Data
        , post
        , query
        , decoder
        )

import GraphqlToElm.Http
import Json.Decode
import Json.Encode


post : String -> GraphqlToElm.Http.Request Data
post url =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = Json.Encode.null
        }
        decoder


query : String
query =
    """{
  pets_pet

  pets_petOrNull

  petsOrNull_pet

  petsOrNull_petOrNull
}"""


type alias Data =
    { pets_pet : List String
    , pets_petOrNull : List (Maybe.Maybe String)
    , petsOrNull_pet : Maybe.Maybe (List String)
    , petsOrNull_petOrNull : Maybe.Maybe (List (Maybe.Maybe String))
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map4 Data
        (Json.Decode.field "pets_pet" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "pets_petOrNull" (Json.Decode.list (Json.Decode.nullable Json.Decode.string)))
        (Json.Decode.field "petsOrNull_pet" (Json.Decode.nullable (Json.Decode.list Json.Decode.string)))
        (Json.Decode.field "petsOrNull_petOrNull" (Json.Decode.nullable (Json.Decode.list (Json.Decode.nullable Json.Decode.string))))
