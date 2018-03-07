module GraphqlToElm.Optional
    exposing
        ( Optional(Present, Null, Absent)
        , map
        , withDefault
        , toMaybe
        , fromMaybe
        )



type Optional a
    = Present a
    | Null
    | Absent


map : (a -> b) -> Optional a -> Optional b
map mapper optional =
    case optional of
        Present a ->
            Present (mapper a)

        Null ->
            Null

        Absent ->
            Absent


withDefault : a -> Optional a -> a
withDefault default optional =
    case optional of
        Present a ->
            a

        _ ->
            default


toMaybe : Optional a -> Maybe a
toMaybe optional =
    case optional of
        Present a ->
            Just a

        _ ->
            Nothing


fromMaybe : Maybe a -> Optional a -> Optional a
fromMaybe maybe default =
    case maybe of
        Just a ->
            Present a

        Nothing ->
            default
