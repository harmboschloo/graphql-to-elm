module Query
    exposing
        ( Query
        , ElmKeywords
        , OtherElmKeywords
        , ElmBasics
        , Bool2
        , List2
        , GraphqlToElmReservedWords
        , Misc
        , query
        )

import GraphqlToElm.Errors
import GraphqlToElm.Operation
import Json.Decode


query : GraphqlToElm.Operation.Operation GraphqlToElm.Operation.Query GraphqlToElm.Errors.Errors Query
query =
    GraphqlToElm.Operation.query
        """{
elmKeywords {
as
case
else
exposing
if
import
in
let
# module
# of
# port
# then
# type
# where
}
otherElmKeywords {
alias
command
effect
false
infix
left
non
null
# right
# subscription
# true
}
elmBasics {
not
flip
String
Int
infix
min
Just
True
}
boolean {
is
}
list {
is
}
graphqlToElmReservedWords {
Variables
Data
query
encodeVariables
decoder
}
misc {
else
else_
type_
Variables2
decoder2
}
}"""
        Maybe.Nothing
        queryDecoder
        GraphqlToElm.Errors.decoder


type alias Query =
    { elmKeywords : ElmKeywords
    , otherElmKeywords : OtherElmKeywords
    , elmBasics : ElmBasics
    , boolean : Bool2
    , list : List List2
    , graphqlToElmReservedWords : GraphqlToElmReservedWords
    , misc : Misc
    }


queryDecoder : Json.Decode.Decoder Query
queryDecoder =
    Json.Decode.map7 Query
        (Json.Decode.field "elmKeywords" elmKeywordsDecoder)
        (Json.Decode.field "otherElmKeywords" otherElmKeywordsDecoder)
        (Json.Decode.field "elmBasics" elmBasicsDecoder)
        (Json.Decode.field "boolean" bool2Decoder)
        (Json.Decode.field "list" (Json.Decode.list list2Decoder))
        (Json.Decode.field "graphqlToElmReservedWords" graphqlToElmReservedWordsDecoder)
        (Json.Decode.field "misc" miscDecoder)


type alias ElmKeywords =
    { as_ : String
    , case_ : Bool
    , else_ : Int
    , exposing_ : Float
    , if_ : List String
    , import_ : String
    , in_ : String
    , let_ : String
    }


elmKeywordsDecoder : Json.Decode.Decoder ElmKeywords
elmKeywordsDecoder =
    Json.Decode.map8 ElmKeywords
        (Json.Decode.field "as" Json.Decode.string)
        (Json.Decode.field "case" Json.Decode.bool)
        (Json.Decode.field "else" Json.Decode.int)
        (Json.Decode.field "exposing" Json.Decode.float)
        (Json.Decode.field "if" (Json.Decode.list Json.Decode.string))
        (Json.Decode.field "import" Json.Decode.string)
        (Json.Decode.field "in" Json.Decode.string)
        (Json.Decode.field "let" Json.Decode.string)


type alias OtherElmKeywords =
    { alias : String
    , command : String
    , effect : String
    , false : String
    , infix : String
    , left : String
    , non : String
    , null : String
    }


otherElmKeywordsDecoder : Json.Decode.Decoder OtherElmKeywords
otherElmKeywordsDecoder =
    Json.Decode.map8 OtherElmKeywords
        (Json.Decode.field "alias" Json.Decode.string)
        (Json.Decode.field "command" Json.Decode.string)
        (Json.Decode.field "effect" Json.Decode.string)
        (Json.Decode.field "false" Json.Decode.string)
        (Json.Decode.field "infix" Json.Decode.string)
        (Json.Decode.field "left" Json.Decode.string)
        (Json.Decode.field "non" Json.Decode.string)
        (Json.Decode.field "null" Json.Decode.string)


type alias ElmBasics =
    { not : String
    , flip : String
    , string : String
    , int : String
    , infix : String
    , min : String
    , just : String
    , true : String
    }


elmBasicsDecoder : Json.Decode.Decoder ElmBasics
elmBasicsDecoder =
    Json.Decode.map8 ElmBasics
        (Json.Decode.field "not" Json.Decode.string)
        (Json.Decode.field "flip" Json.Decode.string)
        (Json.Decode.field "String" Json.Decode.string)
        (Json.Decode.field "Int" Json.Decode.string)
        (Json.Decode.field "infix" Json.Decode.string)
        (Json.Decode.field "min" Json.Decode.string)
        (Json.Decode.field "Just" Json.Decode.string)
        (Json.Decode.field "True" Json.Decode.string)


type alias Bool2 =
    { is : Int
    }


bool2Decoder : Json.Decode.Decoder Bool2
bool2Decoder =
    Json.Decode.map Bool2
        (Json.Decode.field "is" Json.Decode.int)


type alias List2 =
    { is : Int
    }


list2Decoder : Json.Decode.Decoder List2
list2Decoder =
    Json.Decode.map List2
        (Json.Decode.field "is" Json.Decode.int)


type alias GraphqlToElmReservedWords =
    { variables : String
    , data : String
    , query : String
    , encodeVariables : String
    , decoder : String
    }


graphqlToElmReservedWordsDecoder : Json.Decode.Decoder GraphqlToElmReservedWords
graphqlToElmReservedWordsDecoder =
    Json.Decode.map5 GraphqlToElmReservedWords
        (Json.Decode.field "Variables" Json.Decode.string)
        (Json.Decode.field "Data" Json.Decode.string)
        (Json.Decode.field "query" Json.Decode.string)
        (Json.Decode.field "encodeVariables" Json.Decode.string)
        (Json.Decode.field "decoder" Json.Decode.string)


type alias Misc =
    { else_ : String
    , else_2 : String
    , type_ : String
    , variables2 : String
    , decoder2 : String
    }


miscDecoder : Json.Decode.Decoder Misc
miscDecoder =
    Json.Decode.map5 Misc
        (Json.Decode.field "else" Json.Decode.string)
        (Json.Decode.field "else_" Json.Decode.string)
        (Json.Decode.field "type_" Json.Decode.string)
        (Json.Decode.field "Variables2" Json.Decode.string)
        (Json.Decode.field "decoder2" Json.Decode.string)
