module Bartleby.Type.Number exposing
    ( Number
    , decode
    , encode
    , fromFloat
    , maximum
    , minimum
    , toFloat
    )

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
toFloat (Number x) =
    x


decode : Decode.Decoder Number
decode =
    Decode.map fromFloat (Utility.decodeViaString Decode.float)


encode : Number -> Encode.Value
encode x =
    Utility.encodeViaString Encode.float (toFloat x)


maximum : Number -> Number -> Number
maximum =
    viaFloat2 max


minimum : Number -> Number -> Number
minimum =
    viaFloat2 min


viaFloat2 : (Float -> Float -> Float) -> Number -> Number -> Number
viaFloat2 f x y =
    fromFloat (f (toFloat x) (toFloat y))
