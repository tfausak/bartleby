module Bartleby.Type.Number exposing
    ( Number
    , decode
    , encode
    , fromFloat
    , maximum
    , minimum
    , toFloat
    )

import Bartleby.Utility.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Extra as Decode
import Json.Encode as Encode
import Json.Encode.Extra as Encode


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
    Decode.map fromFloat Decode.parseFloat


encode : Number -> Encode.Value
encode x =
    Encode.renderFloat (toFloat x)


maximum : Number -> Number -> Number
maximum =
    viaFloat2 max


minimum : Number -> Number -> Number
minimum =
    viaFloat2 min


viaFloat2 : (Float -> Float -> Float) -> Number -> Number -> Number
viaFloat2 f x y =
    fromFloat (f (toFloat x) (toFloat y))
