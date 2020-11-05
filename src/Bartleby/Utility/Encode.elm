module Bartleby.Utility.Encode exposing (renderFloat)

import Json.Encode as Encode


renderFloat : Float -> Encode.Value
renderFloat x =
    Encode.string (String.fromFloat x)
