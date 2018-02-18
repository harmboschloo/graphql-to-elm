module Query exposing (Data, ElmBasics, ElmKeywords, GraphqlToElmReservedWords, Misc, OtherElmKeywords, decoder, query)

import Json.Decode


query : String
query =
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


type alias Data =
    { elmBasics : ElmBasics
    , elmKeywords : ElmKeywords
    , graphqlToElmReservedWords : GraphqlToElmReservedWords
    , misc : Misc
    , otherElmKeywords : OtherElmKeywords
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map5 Data
        (Json.Decode.field "elmBasics" elmBasicsDecoder)
        (Json.Decode.field "elmKeywords" elmKeywordsDecoder)
        (Json.Decode.field "graphqlToElmReservedWords" graphqlToElmReservedWordsDecoder)
        (Json.Decode.field "misc" miscDecoder)
        (Json.Decode.field "otherElmKeywords" otherElmKeywordsDecoder)


type alias ElmKeywords =
    { as_ : String
    , case_ : String
    , else_ : String
    , exposing_ : String
    , if_ : String
    , import_ : String
    , in_ : String
    , let_ : String
    }


elmKeywordsDecoder : Json.Decode.Decoder ElmKeywords
elmKeywordsDecoder =
    Json.Decode.map8 ElmKeywords
        (Json.Decode.field "as" Json.Decode.string)
        (Json.Decode.field "case" Json.Decode.string)
        (Json.Decode.field "else" Json.Decode.string)
        (Json.Decode.field "exposing" Json.Decode.string)
        (Json.Decode.field "if" Json.Decode.string)
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
    { int : String
    , just : String
    , string : String
    , true : String
    , flip : String
    , infix : String
    , min : String
    , not : String
    }


elmBasicsDecoder : Json.Decode.Decoder ElmBasics
elmBasicsDecoder =
    Json.Decode.map8 ElmBasics
        (Json.Decode.field "Int" Json.Decode.string)
        (Json.Decode.field "Just" Json.Decode.string)
        (Json.Decode.field "String" Json.Decode.string)
        (Json.Decode.field "True" Json.Decode.string)
        (Json.Decode.field "flip" Json.Decode.string)
        (Json.Decode.field "infix" Json.Decode.string)
        (Json.Decode.field "min" Json.Decode.string)
        (Json.Decode.field "not" Json.Decode.string)


type alias GraphqlToElmReservedWords =
    { data : String
    , variables : String
    , decoder : String
    , encodeVariables : String
    , query : String
    }


graphqlToElmReservedWordsDecoder : Json.Decode.Decoder GraphqlToElmReservedWords
graphqlToElmReservedWordsDecoder =
    Json.Decode.map5 GraphqlToElmReservedWords
        (Json.Decode.field "Data" Json.Decode.string)
        (Json.Decode.field "Variables" Json.Decode.string)
        (Json.Decode.field "decoder" Json.Decode.string)
        (Json.Decode.field "encodeVariables" Json.Decode.string)
        (Json.Decode.field "query" Json.Decode.string)


type alias Misc =
    { variables2 : String
    , decoder2 : String
    , else_ : String
    , else_2 : String
    , type_ : String
    }


miscDecoder : Json.Decode.Decoder Misc
miscDecoder =
    Json.Decode.map5 Misc
        (Json.Decode.field "Variables2" Json.Decode.string)
        (Json.Decode.field "decoder2" Json.Decode.string)
        (Json.Decode.field "else" Json.Decode.string)
        (Json.Decode.field "else_" Json.Decode.string)
        (Json.Decode.field "type_" Json.Decode.string)
