module Bartleby.Utility.Encode exposing
    ( maybe
    , viaString
    )

import Json.Encode as Encode
import Maybe.Extra as Maybe


maybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
maybe =
    Maybe.unwrap Encode.null


{-| Encodes some value, then encodes the result as a string. This is useful to
encode a number as something like `"1.2"` instead of simply `1.2`.
-}
viaString : (a -> Encode.Value) -> a -> Encode.Value
viaString encode x =
    Encode.string (Encode.encode 0 (encode x))
