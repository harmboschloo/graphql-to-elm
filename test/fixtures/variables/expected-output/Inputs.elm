module Inputs
    exposing
        ( InputsVariables
        , Inputs
        , OtherInputs
        , Query
        , inputs
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode
import Json.Encode


inputs : InputsVariables -> GraphqlToElm.Operation.Operation GraphqlToElm.Errors.Errors Query
inputs variables =
    GraphqlToElm.Operation.query
        """query Inputs($inputs: Inputs!) {
inputs(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsVariables variables)
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias InputsVariables =
    { inputs : Inputs
    }


encodeInputsVariables : InputsVariables -> Json.Encode.Value
encodeInputsVariables inputs =
    Json.Encode.object
        [ ( "inputs", encodeInputs inputs.inputs )
        ]


type alias Inputs =
    { int : Int
    , float : Float
    , other : OtherInputs
    }


encodeInputs : Inputs -> Json.Encode.Value
encodeInputs inputs =
    Json.Encode.object
        [ ( "int", Json.Encode.int inputs.int )
        , ( "float", Json.Encode.float inputs.float )
        , ( "other", encodeOtherInputs inputs.other )
        ]


type alias OtherInputs =
    { string : String
    }


encodeOtherInputs : OtherInputs -> Json.Encode.Value
encodeOtherInputs inputs =
    Json.Encode.object
        [ ( "string", Json.Encode.string inputs.string )
        ]


type alias Query =
    { inputs : Maybe.Maybe String
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map Query
        (Json.Decode.field "inputs" (Json.Decode.nullable Json.Decode.string))
