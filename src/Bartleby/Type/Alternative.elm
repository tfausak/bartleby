module Bartleby.Type.Alternative exposing (Alternative, decode, encode)

import Bartleby.Type.Number as Number
import Json.Decode as Decode
import Json.Encode as Encode


{-| The confidence is a number between 0.00 and 1.00, where 0.00 means "not
confident at all" and 1.00 means "completely confident".
-}
type alias Alternative =
    { confidence : Number.Number
    , content : String
    }


decode : Decode.Decoder Alternative
decode =
    Decode.map2 Alternative
        (Decode.field "confidence" Number.decode)
        (Decode.field "content" Decode.string)


encode : Alternative -> Encode.Value
encode alternative =
    Encode.object
        [ ( "confidence", Number.encode alternative.confidence )
        , ( "content", Encode.string alternative.content )
        ]
