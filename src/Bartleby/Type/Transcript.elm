module Bartleby.Type.Transcript exposing
    ( Transcript
    , decode
    , encode
    )

import Json.Decode as Decode
import Json.Encode as Encode


type alias Transcript =
    { transcript : String
    }


decode : Decode.Decoder Transcript
decode =
    Decode.map Transcript
        (Decode.field "transcript" Decode.string)


encode : Transcript -> Encode.Value
encode x =
    Encode.object
        [ ( "transcript", Encode.string x.transcript )
        ]
