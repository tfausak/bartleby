module Bartleby.Utility exposing (decodeViaString, encodeMaybe, encodeViaString, maybe)

import Json.Decode as Decode
import Json.Encode as Encode


{-| Decodes some value that is wrapped in a string. This is useful if a number
is encoded as something like `"1.2"` instead of simply `1.2`.
-}
decodeViaString : Decode.Decoder a -> Decode.Decoder a
decodeViaString decode =
    Decode.andThen
        (\string ->
            case Decode.decodeString decode string of
                Err err ->
                    Decode.fail (Decode.errorToString err)

                Ok ok ->
                    Decode.succeed ok
        )
        Decode.string


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe =
    maybe Encode.null


{-| Encodes some value, then encodes the result as a string. This is useful to
encode a number as something like `"1.2"` instead of simply `1.2`.
-}
encodeViaString : (a -> Encode.Value) -> a -> Encode.Value
encodeViaString encode x =
    Encode.string (Encode.encode 0 (encode x))


maybe : b -> (a -> b) -> Maybe a -> b
maybe d f m =
    case m of
        Nothing ->
            d

        Just x ->
            f x
