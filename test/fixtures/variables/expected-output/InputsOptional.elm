module InputsOptional
    exposing
        ( Variables
        , OptionalInputs
        , OtherInputs
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
    """query InputsOptional($inputs: OptionalInputs) {
  inputsOptional(inputs: $inputs)
}"""


type alias Variables =
    { inputs : GraphqlToElm.Optional.Optional OptionalInputs
    }


encodeVariables : Variables -> Json.Encode.Value
encodeVariables inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "inputs", (GraphqlToElm.Optional.map encodeOptionalInputs) inputs.inputs )
        ]


type alias OptionalInputs =
    { int : GraphqlToElm.Optional.Optional Int
    , float : GraphqlToElm.Optional.Optional Float
    , other : GraphqlToElm.Optional.Optional OtherInputs
    }


encodeOptionalInputs : OptionalInputs -> Json.Encode.Value
encodeOptionalInputs inputs =
    GraphqlToElm.Optional.encodeObject
        [ ( "int", (GraphqlToElm.Optional.map Json.Encode.int) inputs.int )
        , ( "float", (GraphqlToElm.Optional.map Json.Encode.float) inputs.float )
        , ( "other", (GraphqlToElm.Optional.map encodeOtherInputs) inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


type alias Data =
    { inputsOptional : Maybe.Maybe String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "inputsOptional" (Json.Decode.nullable Json.Decode.string))
