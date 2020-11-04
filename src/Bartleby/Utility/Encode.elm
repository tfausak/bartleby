module Bartleby.Utility.Encode exposing
    ( maybe
    , viaString
    )

import Bartleby.Utility.Maybe as Maybe
import Json.Encode as Encode


maybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
maybe =
    Maybe.maybe Encode.null


{-| Encodes some value, then encodes the result as a string. This is useful to
encode a number as something like `"1.2"` instead of simply `1.2`.
-}
viaString : (a -> Encode.Value) -> a -> Encode.Value
viaString encode x =
    Encode.string (Encode.encode 0 (encode x))
