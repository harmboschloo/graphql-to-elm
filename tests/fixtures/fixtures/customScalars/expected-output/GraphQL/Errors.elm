module GraphQL.Errors exposing
    ( Errors, Error, Location, decoder
    , errorDecoder, locationDecoder
    )

{-| Types and decoder for the errors field in the GraphQL response.
See <http://facebook.github.io/graphql/October2016/#sec-Errors>.

@docs Errors, Error, Location, decoder

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
    }


{-| -}
type alias Location =
    { line : Int
    , column : Int
    }


{-| -}
decoder : Decoder Errors
decoder =
    Decode.list errorDecoder


{-| -}
errorDecoder : Decoder Error
errorDecoder =
    Decode.map2 Error
        (Decode.field "message" Decode.string)
        (Optional.nonNullFieldDecoder "locations" <| Decode.list locationDecoder)


{-| -}
locationDecoder : Decoder Location
locationDecoder =
    Decode.map2 Location
        (Decode.field "line" Decode.int)
        (Decode.field "column" Decode.int)
