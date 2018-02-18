module GraphqlToElm.Input.Optional exposing (Optional(..))


type Optional a
    = Present a
    | Null
    | Absent
