module Inputs
    exposing
        ( InputsVariables
        , Inputs
        , OtherInputs
        , Query
        , inputs
        )

import GraphqlToElm.Graphql.Errors
import GraphqlToElm.Graphql.Operation
import Json.Decode
import Json.Encode


inputs : InputsVariables -> GraphqlToElm.Graphql.Operation.Operation GraphqlToElm.Graphql.Errors.Errors Query
inputs variables =
    GraphqlToElm.Graphql.Operation.query
        """query Inputs($inputs: Inputs!) {
inputs(inputs: $inputs)
}"""
        (Maybe.Just <| encodeInputsVariables variables)
        queryDecoder
        GraphqlToElm.Graphql.Errors.decoder


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
