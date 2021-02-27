module Recursive exposing
    ( RecursiveInput
    , RecursiveInput10
    , RecursiveInput11
    , RecursiveInput12
    , RecursiveInput13
    , RecursiveInput14
    , RecursiveInput15
    , RecursiveInput16
    , RecursiveInput17
    , RecursiveInput18
    , RecursiveInput19
    , RecursiveInput2
    , RecursiveInput20
    , RecursiveInput21
    , RecursiveInput22
    , RecursiveInput23
    , RecursiveInput24
    , RecursiveInput25
    , RecursiveInput26
    , RecursiveInput27
    , RecursiveInput28
    , RecursiveInput29
    , RecursiveInput3
    , RecursiveInput30
    , RecursiveInput31
    , RecursiveInput32
    , RecursiveInput33
    , RecursiveInput34
    , RecursiveInput35
    , RecursiveInput36
    , RecursiveInput37
    , RecursiveInput38
    , RecursiveInput39
    , RecursiveInput4
    , RecursiveInput40
    , RecursiveInput41
    , RecursiveInput42
    , RecursiveInput43
    , RecursiveInput44
    , RecursiveInput45
    , RecursiveInput46
    , RecursiveInput47
    , RecursiveInput48
    , RecursiveInput49
    , RecursiveInput5
    , RecursiveInput50
    , RecursiveInput6
    , RecursiveInput7
    , RecursiveInput8
    , RecursiveInput9
    , RecursiveQuery
    , RecursiveResponse
    , RecursiveVariables
    , recursive
    )

import GraphQL.Errors
import GraphQL.Operation
import GraphQL.Optional
import GraphQL.Response
import Json.Decode
import Json.Encode


recursive : RecursiveVariables -> GraphQL.Operation.Operation GraphQL.Operation.Query GraphQL.Errors.Errors RecursiveQuery
recursive variables =
    GraphQL.Operation.withQuery
        """query Recursive($input: RecursiveInput!) {
recursive(input: $input)
}"""
        (Maybe.Just <| encodeRecursiveVariables variables)
        recursiveQueryDecoder
        GraphQL.Errors.decoder


type alias RecursiveResponse =
    GraphQL.Response.Response GraphQL.Errors.Errors RecursiveQuery


type alias RecursiveVariables =
    { input : RecursiveInput50
    }


encodeRecursiveVariables : RecursiveVariables -> Json.Encode.Value
encodeRecursiveVariables inputs =
    Json.Encode.object
        [ ( "input", encodeRecursiveInput50 inputs.input )
        ]


type alias RecursiveInput50 =
    { child : GraphQL.Optional.Optional RecursiveInput49
    }


encodeRecursiveInput50 : RecursiveInput50 -> Json.Encode.Value
encodeRecursiveInput50 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput49 inputs.child )
        ]


type alias RecursiveInput49 =
    { child : GraphQL.Optional.Optional RecursiveInput48
    }


encodeRecursiveInput49 : RecursiveInput49 -> Json.Encode.Value
encodeRecursiveInput49 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput48 inputs.child )
        ]


type alias RecursiveInput48 =
    { child : GraphQL.Optional.Optional RecursiveInput47
    }


encodeRecursiveInput48 : RecursiveInput48 -> Json.Encode.Value
encodeRecursiveInput48 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput47 inputs.child )
        ]


type alias RecursiveInput47 =
    { child : GraphQL.Optional.Optional RecursiveInput46
    }


encodeRecursiveInput47 : RecursiveInput47 -> Json.Encode.Value
encodeRecursiveInput47 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput46 inputs.child )
        ]


type alias RecursiveInput46 =
    { child : GraphQL.Optional.Optional RecursiveInput45
    }


encodeRecursiveInput46 : RecursiveInput46 -> Json.Encode.Value
encodeRecursiveInput46 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput45 inputs.child )
        ]


type alias RecursiveInput45 =
    { child : GraphQL.Optional.Optional RecursiveInput44
    }


encodeRecursiveInput45 : RecursiveInput45 -> Json.Encode.Value
encodeRecursiveInput45 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput44 inputs.child )
        ]


type alias RecursiveInput44 =
    { child : GraphQL.Optional.Optional RecursiveInput43
    }


encodeRecursiveInput44 : RecursiveInput44 -> Json.Encode.Value
encodeRecursiveInput44 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput43 inputs.child )
        ]


type alias RecursiveInput43 =
    { child : GraphQL.Optional.Optional RecursiveInput42
    }


encodeRecursiveInput43 : RecursiveInput43 -> Json.Encode.Value
encodeRecursiveInput43 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput42 inputs.child )
        ]


type alias RecursiveInput42 =
    { child : GraphQL.Optional.Optional RecursiveInput41
    }


encodeRecursiveInput42 : RecursiveInput42 -> Json.Encode.Value
encodeRecursiveInput42 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput41 inputs.child )
        ]


type alias RecursiveInput41 =
    { child : GraphQL.Optional.Optional RecursiveInput40
    }


encodeRecursiveInput41 : RecursiveInput41 -> Json.Encode.Value
encodeRecursiveInput41 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput40 inputs.child )
        ]


type alias RecursiveInput40 =
    { child : GraphQL.Optional.Optional RecursiveInput39
    }


encodeRecursiveInput40 : RecursiveInput40 -> Json.Encode.Value
encodeRecursiveInput40 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput39 inputs.child )
        ]


type alias RecursiveInput39 =
    { child : GraphQL.Optional.Optional RecursiveInput38
    }


encodeRecursiveInput39 : RecursiveInput39 -> Json.Encode.Value
encodeRecursiveInput39 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput38 inputs.child )
        ]


type alias RecursiveInput38 =
    { child : GraphQL.Optional.Optional RecursiveInput37
    }


encodeRecursiveInput38 : RecursiveInput38 -> Json.Encode.Value
encodeRecursiveInput38 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput37 inputs.child )
        ]


type alias RecursiveInput37 =
    { child : GraphQL.Optional.Optional RecursiveInput36
    }


encodeRecursiveInput37 : RecursiveInput37 -> Json.Encode.Value
encodeRecursiveInput37 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput36 inputs.child )
        ]


type alias RecursiveInput36 =
    { child : GraphQL.Optional.Optional RecursiveInput35
    }


encodeRecursiveInput36 : RecursiveInput36 -> Json.Encode.Value
encodeRecursiveInput36 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput35 inputs.child )
        ]


type alias RecursiveInput35 =
    { child : GraphQL.Optional.Optional RecursiveInput34
    }


encodeRecursiveInput35 : RecursiveInput35 -> Json.Encode.Value
encodeRecursiveInput35 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput34 inputs.child )
        ]


type alias RecursiveInput34 =
    { child : GraphQL.Optional.Optional RecursiveInput33
    }


encodeRecursiveInput34 : RecursiveInput34 -> Json.Encode.Value
encodeRecursiveInput34 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput33 inputs.child )
        ]


type alias RecursiveInput33 =
    { child : GraphQL.Optional.Optional RecursiveInput32
    }


encodeRecursiveInput33 : RecursiveInput33 -> Json.Encode.Value
encodeRecursiveInput33 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput32 inputs.child )
        ]


type alias RecursiveInput32 =
    { child : GraphQL.Optional.Optional RecursiveInput31
    }


encodeRecursiveInput32 : RecursiveInput32 -> Json.Encode.Value
encodeRecursiveInput32 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput31 inputs.child )
        ]


type alias RecursiveInput31 =
    { child : GraphQL.Optional.Optional RecursiveInput30
    }


encodeRecursiveInput31 : RecursiveInput31 -> Json.Encode.Value
encodeRecursiveInput31 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput30 inputs.child )
        ]


type alias RecursiveInput30 =
    { child : GraphQL.Optional.Optional RecursiveInput29
    }


encodeRecursiveInput30 : RecursiveInput30 -> Json.Encode.Value
encodeRecursiveInput30 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput29 inputs.child )
        ]


type alias RecursiveInput29 =
    { child : GraphQL.Optional.Optional RecursiveInput28
    }


encodeRecursiveInput29 : RecursiveInput29 -> Json.Encode.Value
encodeRecursiveInput29 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput28 inputs.child )
        ]


type alias RecursiveInput28 =
    { child : GraphQL.Optional.Optional RecursiveInput27
    }


encodeRecursiveInput28 : RecursiveInput28 -> Json.Encode.Value
encodeRecursiveInput28 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput27 inputs.child )
        ]


type alias RecursiveInput27 =
    { child : GraphQL.Optional.Optional RecursiveInput26
    }


encodeRecursiveInput27 : RecursiveInput27 -> Json.Encode.Value
encodeRecursiveInput27 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput26 inputs.child )
        ]


type alias RecursiveInput26 =
    { child : GraphQL.Optional.Optional RecursiveInput25
    }


encodeRecursiveInput26 : RecursiveInput26 -> Json.Encode.Value
encodeRecursiveInput26 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput25 inputs.child )
        ]


type alias RecursiveInput25 =
    { child : GraphQL.Optional.Optional RecursiveInput24
    }


encodeRecursiveInput25 : RecursiveInput25 -> Json.Encode.Value
encodeRecursiveInput25 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput24 inputs.child )
        ]


type alias RecursiveInput24 =
    { child : GraphQL.Optional.Optional RecursiveInput23
    }


encodeRecursiveInput24 : RecursiveInput24 -> Json.Encode.Value
encodeRecursiveInput24 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput23 inputs.child )
        ]


type alias RecursiveInput23 =
    { child : GraphQL.Optional.Optional RecursiveInput22
    }


encodeRecursiveInput23 : RecursiveInput23 -> Json.Encode.Value
encodeRecursiveInput23 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput22 inputs.child )
        ]


type alias RecursiveInput22 =
    { child : GraphQL.Optional.Optional RecursiveInput21
    }


encodeRecursiveInput22 : RecursiveInput22 -> Json.Encode.Value
encodeRecursiveInput22 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput21 inputs.child )
        ]


type alias RecursiveInput21 =
    { child : GraphQL.Optional.Optional RecursiveInput20
    }


encodeRecursiveInput21 : RecursiveInput21 -> Json.Encode.Value
encodeRecursiveInput21 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput20 inputs.child )
        ]


type alias RecursiveInput20 =
    { child : GraphQL.Optional.Optional RecursiveInput19
    }


encodeRecursiveInput20 : RecursiveInput20 -> Json.Encode.Value
encodeRecursiveInput20 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput19 inputs.child )
        ]


type alias RecursiveInput19 =
    { child : GraphQL.Optional.Optional RecursiveInput18
    }


encodeRecursiveInput19 : RecursiveInput19 -> Json.Encode.Value
encodeRecursiveInput19 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput18 inputs.child )
        ]


type alias RecursiveInput18 =
    { child : GraphQL.Optional.Optional RecursiveInput17
    }


encodeRecursiveInput18 : RecursiveInput18 -> Json.Encode.Value
encodeRecursiveInput18 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput17 inputs.child )
        ]


type alias RecursiveInput17 =
    { child : GraphQL.Optional.Optional RecursiveInput16
    }


encodeRecursiveInput17 : RecursiveInput17 -> Json.Encode.Value
encodeRecursiveInput17 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput16 inputs.child )
        ]


type alias RecursiveInput16 =
    { child : GraphQL.Optional.Optional RecursiveInput15
    }


encodeRecursiveInput16 : RecursiveInput16 -> Json.Encode.Value
encodeRecursiveInput16 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput15 inputs.child )
        ]


type alias RecursiveInput15 =
    { child : GraphQL.Optional.Optional RecursiveInput14
    }


encodeRecursiveInput15 : RecursiveInput15 -> Json.Encode.Value
encodeRecursiveInput15 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput14 inputs.child )
        ]


type alias RecursiveInput14 =
    { child : GraphQL.Optional.Optional RecursiveInput13
    }


encodeRecursiveInput14 : RecursiveInput14 -> Json.Encode.Value
encodeRecursiveInput14 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput13 inputs.child )
        ]


type alias RecursiveInput13 =
    { child : GraphQL.Optional.Optional RecursiveInput12
    }


encodeRecursiveInput13 : RecursiveInput13 -> Json.Encode.Value
encodeRecursiveInput13 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput12 inputs.child )
        ]


type alias RecursiveInput12 =
    { child : GraphQL.Optional.Optional RecursiveInput11
    }


encodeRecursiveInput12 : RecursiveInput12 -> Json.Encode.Value
encodeRecursiveInput12 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput11 inputs.child )
        ]


type alias RecursiveInput11 =
    { child : GraphQL.Optional.Optional RecursiveInput10
    }


encodeRecursiveInput11 : RecursiveInput11 -> Json.Encode.Value
encodeRecursiveInput11 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput10 inputs.child )
        ]


type alias RecursiveInput10 =
    { child : GraphQL.Optional.Optional RecursiveInput9
    }


encodeRecursiveInput10 : RecursiveInput10 -> Json.Encode.Value
encodeRecursiveInput10 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput9 inputs.child )
        ]


type alias RecursiveInput9 =
    { child : GraphQL.Optional.Optional RecursiveInput8
    }


encodeRecursiveInput9 : RecursiveInput9 -> Json.Encode.Value
encodeRecursiveInput9 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput8 inputs.child )
        ]


type alias RecursiveInput8 =
    { child : GraphQL.Optional.Optional RecursiveInput7
    }


encodeRecursiveInput8 : RecursiveInput8 -> Json.Encode.Value
encodeRecursiveInput8 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput7 inputs.child )
        ]


type alias RecursiveInput7 =
    { child : GraphQL.Optional.Optional RecursiveInput6
    }


encodeRecursiveInput7 : RecursiveInput7 -> Json.Encode.Value
encodeRecursiveInput7 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput6 inputs.child )
        ]


type alias RecursiveInput6 =
    { child : GraphQL.Optional.Optional RecursiveInput5
    }


encodeRecursiveInput6 : RecursiveInput6 -> Json.Encode.Value
encodeRecursiveInput6 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput5 inputs.child )
        ]


type alias RecursiveInput5 =
    { child : GraphQL.Optional.Optional RecursiveInput4
    }


encodeRecursiveInput5 : RecursiveInput5 -> Json.Encode.Value
encodeRecursiveInput5 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput4 inputs.child )
        ]


type alias RecursiveInput4 =
    { child : GraphQL.Optional.Optional RecursiveInput3
    }


encodeRecursiveInput4 : RecursiveInput4 -> Json.Encode.Value
encodeRecursiveInput4 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput3 inputs.child )
        ]


type alias RecursiveInput3 =
    { child : GraphQL.Optional.Optional RecursiveInput2
    }


encodeRecursiveInput3 : RecursiveInput3 -> Json.Encode.Value
encodeRecursiveInput3 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput2 inputs.child )
        ]


type alias RecursiveInput2 =
    { child : GraphQL.Optional.Optional RecursiveInput
    }


encodeRecursiveInput2 : RecursiveInput2 -> Json.Encode.Value
encodeRecursiveInput2 inputs =
    GraphQL.Optional.encodeObject
        [ ( "child", GraphQL.Optional.map encodeRecursiveInput inputs.child )
        ]


type alias RecursiveInput =
    {}


encodeRecursiveInput : RecursiveInput -> Json.Encode.Value
encodeRecursiveInput inputs =
    Json.Encode.object []


type alias RecursiveQuery =
    { recursive : Maybe.Maybe String
    }


recursiveQueryDecoder : Json.Decode.Decoder RecursiveQuery
recursiveQueryDecoder =
    Json.Decode.map RecursiveQuery
        (Json.Decode.field "recursive" (Json.Decode.nullable Json.Decode.string))
