module Include
    exposing
        ( Variables
        , Data
        , query
        , encodeVariables
        , decoder
        )

import Json.Decode
import Json.Encode
import GraphqlToElm.Optional


query : String
query =
    """query Include($withSchool: Boolean!, $withCity: Boolean!) {
  name
  school @include(if: $withSchool)
  city @include(if: $withCity)
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
        (GraphqlToElm.Optional.fieldDecoder "school" Json.Decode.string |> Json.Decode.map GraphqlToElm.Optional.toMaybe)
        (GraphqlToElm.Optional.fieldDecoder "city" Json.Decode.string)
