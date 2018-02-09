module Generated.Tests exposing (Test, tests)

import Json.Decode exposing (Decoder)
import Json.Encode
import Generated.Test0LineEndingsLf.Lf
import Generated.Test1LineEndingsCrlf.Crlf
import Generated.Test2ListsOfObjects.ListOfObjects
import Generated.Test3ListsOfScalars.ListOfScalars
import Generated.Test4Misc.Query
import Generated.Test5ObjectsBasic.Basic
import Generated.Test6ObjectsNested.Nested
import Generated.Test7ObjectsSameTypeSameFields.SameTypeSameFields
import Generated.Test8ObjectsSameTypeSameFieldsNullable.SameTypeSameFieldsNullable
import Generated.Test9ObjectsSameTypeSameFieldsList.SameTypeSameFieldsList
import Generated.Test10ObjectsSameTypeOtherFields.SameTypeOtherFields
import Generated.Test11ObjectsOtherTypeSameFields.OtherTypeSameFields
import Generated.Test12ObjectsOtherTypeOtherFields.OtherTypeOtherFields
import Generated.Test13DefaultScalarsTypes.DefaultScalarTypes
import Generated.Test14DefaultNullableScalarsTypes.DefaultNullableScalarTypes


type alias Test =
    { id : String
    , query : String
    , variables : Json.Encode.Value
    , decoder : Decoder String
    }


tests : List Test
tests =
    [ { id = "test0-line-endings-lf"
      , query = Generated.Test0LineEndingsLf.Lf.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test0LineEndingsLf.Lf.decoder
      }
    , { id = "test1-line-endings-crlf"
      , query = Generated.Test1LineEndingsCrlf.Crlf.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test1LineEndingsCrlf.Crlf.decoder
      }
    , { id = "test2-lists-of-objects"
      , query = Generated.Test2ListsOfObjects.ListOfObjects.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test2ListsOfObjects.ListOfObjects.decoder
      }
    , { id = "test3-lists-of-scalars"
      , query = Generated.Test3ListsOfScalars.ListOfScalars.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test3ListsOfScalars.ListOfScalars.decoder
      }
    , { id = "test4-misc"
      , query = Generated.Test4Misc.Query.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test4Misc.Query.decoder
      }
    , { id = "test5-objects-basic"
      , query = Generated.Test5ObjectsBasic.Basic.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test5ObjectsBasic.Basic.decoder
      }
    , { id = "test6-objects-nested"
      , query = Generated.Test6ObjectsNested.Nested.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test6ObjectsNested.Nested.decoder
      }
    , { id = "test7-objects-same-type-same-fields"
      , query = Generated.Test7ObjectsSameTypeSameFields.SameTypeSameFields.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test7ObjectsSameTypeSameFields.SameTypeSameFields.decoder
      }
    , { id = "test8-objects-same-type-same-fields-nullable"
      , query = Generated.Test8ObjectsSameTypeSameFieldsNullable.SameTypeSameFieldsNullable.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test8ObjectsSameTypeSameFieldsNullable.SameTypeSameFieldsNullable.decoder
      }
    , { id = "test9-objects-same-type-same-fields-list"
      , query = Generated.Test9ObjectsSameTypeSameFieldsList.SameTypeSameFieldsList.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test9ObjectsSameTypeSameFieldsList.SameTypeSameFieldsList.decoder
      }
    , { id = "test10-objects-same-type-other-fields"
      , query = Generated.Test10ObjectsSameTypeOtherFields.SameTypeOtherFields.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test10ObjectsSameTypeOtherFields.SameTypeOtherFields.decoder
      }
    , { id = "test11-objects-other-type-same-fields"
      , query = Generated.Test11ObjectsOtherTypeSameFields.OtherTypeSameFields.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test11ObjectsOtherTypeSameFields.OtherTypeSameFields.decoder
      }
    , { id = "test12-objects-other-type-other-fields"
      , query = Generated.Test12ObjectsOtherTypeOtherFields.OtherTypeOtherFields.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test12ObjectsOtherTypeOtherFields.OtherTypeOtherFields.decoder
      }
    , { id = "test13-default-scalars-types"
      , query = Generated.Test13DefaultScalarsTypes.DefaultScalarTypes.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test13DefaultScalarsTypes.DefaultScalarTypes.decoder
      }
    , { id = "test14-default-nullable-scalars-types"
      , query = Generated.Test14DefaultNullableScalarsTypes.DefaultNullableScalarTypes.query
      , variables = Json.Encode.null
      , decoder = Json.Decode.map toString Generated.Test14DefaultNullableScalarsTypes.DefaultNullableScalarTypes.decoder
      }
    ]  
