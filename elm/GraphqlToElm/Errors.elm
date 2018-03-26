module GraphqlToElm.Errors
    exposing
        ( Errors
        , Error
        , Location
        , decoder
        )

{-| Types and decoder for the errors field in the GraphQL response.
See <http://facebook.github.io/graphql/October2016/#sec-Errors>.

@docs Errors, Error, Location, decoder

-}

import Json.Decode as Decode exposing (Decoder)
import GraphqlToElm.Optional.Decode as OptionalDecode


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


errorDecoder : Decoder Error
errorDecoder =
    Decode.map2 Error
        (Decode.field "message" Decode.string)
        (OptionalDecode.nonNullField "locations" <| Decode.list locationDecoder)


locationDecoder : Decoder Location
locationDecoder =
    Decode.map2 Location
        (Decode.field "line" Decode.int)
        (Decode.field "column" Decode.int)
