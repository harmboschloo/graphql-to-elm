module GraphQL.Errors exposing
    ( Errors, Error, Location, PathSegment(..)
    , decoder, errorDecoder, locationDecoder, pathSegmentDecoder
    )

{-| Types and decoder for the errors field in the GraphQL response.
See <http://facebook.github.io/graphql/draft/#sec-Errors>.

@docs Errors, Error, Location, PathSegment
@docs decoder, errorDecoder, locationDecoder, pathSegmentDecoder

-}

import GraphQL.Optional as Optional
import Json.Decode as Decode exposing (Decoder)


{-| -}
type alias Errors =
    List Error


{-| -}
type alias Error =
    { message : String
    , locations : Maybe (List Location)
    , path : Maybe (List PathSegment)
    }


{-| -}
type alias Location =
    { line : Int
    , column : Int
    }


{-| -}
type PathSegment
    = FieldName String
    | ListIndex Int


{-| -}
decoder : Decoder Errors
decoder =
    Decode.list errorDecoder


{-| -}
errorDecoder : Decoder Error
errorDecoder =
    Decode.map3 Error
        (Decode.field "message" Decode.string)
        (Optional.nonNullFieldDecoder "locations" <| Decode.list locationDecoder)
        (Optional.nonNullFieldDecoder "path" <| Decode.list pathSegmentDecoder)


{-| -}
locationDecoder : Decoder Location
locationDecoder =
    Decode.map2 Location
        (Decode.field "line" Decode.int)
        (Decode.field "column" Decode.int)


{-| -}
pathSegmentDecoder : Decoder PathSegment
pathSegmentDecoder =
    Decode.oneOf
        [ Decode.map ListIndex Decode.int
        , Decode.map FieldName Decode.string
        ]
