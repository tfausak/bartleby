module Bartleby.Type.Number exposing (Number, decode, encode, fromFloat, toFloat)

import Bartleby.Utility as Utility
import Json.Decode as Decode
import Json.Encode as Encode


{-| This is just a thin wrapper around a float. It's necessary because the job
JSON encodes some numbers as strings rather than numbers directly.
-}
type Number
    = Number Float


fromFloat : Float -> Number
fromFloat =
    Number


toFloat : Number -> Float
toFloat (Number float) =
    float


decode : Decode.Decoder Number
decode =
    Decode.map fromFloat (Utility.decodeViaString Decode.float)


encode : Number -> Encode.Value
encode number =
    Utility.encodeViaString Encode.float (toFloat number)
