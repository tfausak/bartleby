module Bartleby.Utility.Decode exposing (viaString)

import Json.Decode as Decode


{-| Decodes some value that is wrapped in a string. This is useful if a number
is encoded as something like `"1.2"` instead of simply `1.2`.
-}
viaString : Decode.Decoder a -> Decode.Decoder a
viaString decode =
    Decode.andThen
        (\string ->
            case Decode.decodeString decode string of
                Err err ->
                    Decode.fail (Decode.errorToString err)

                Ok ok ->
                    Decode.succeed ok
        )
        Decode.string
