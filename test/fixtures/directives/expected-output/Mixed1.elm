module Mixed1
    exposing
        ( Variables
        , Data
        , post
        , query
        , encodeVariables
        , decoder
        )

import GraphqlToElm.Http
import GraphqlToElm.Optional
import Json.Decode
import Json.Encode


post : String -> Variables -> GraphqlToElm.Http.Request Data
post url variables =
    GraphqlToElm.Http.post
        url
        { query = query
        , variables = encodeVariables variables
        }
        decoder


query : String
query =
    """query Mixed1($withSchool: Boolean!, $withCity: Boolean!) {
  name
  school @include(if: $withSchool)
  city @skip(if: $withCity)
}"""


type alias Variables =
    { withSchool : Bool
    , withCity : Bool
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    Json.Encode.object
        [ ( "withSchool", Json.Encode.bool inputs.withSchool )
        , ( "withCity", Json.Encode.bool inputs.withCity )
        ]


type alias Data =
    { name : String
    , school : Maybe.Maybe String
    , city : GraphqlToElm.Optional.Optional String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map3 Data
        (Json.Decode.field "name" Json.Decode.string)
        (GraphqlToElm.Optional.nonNullfieldDecoder "school" Json.Decode.string)
        (GraphqlToElm.Optional.fieldDecoder "city" Json.Decode.string)
