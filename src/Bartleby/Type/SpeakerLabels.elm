module Bartleby.Type.SpeakerLabels exposing
    ( SpeakerLabels
    , decode
    , encode
    )

import Bartleby.Type.Segment as Segment
import Json.Decode as Decode
import Json.Encode as Encode


type alias SpeakerLabels =
    { segments : List Segment.Segment
    , speakers : Int
    }


decode : Decode.Decoder SpeakerLabels
decode =
    Decode.map2 SpeakerLabels
        (Decode.field "segments" (Decode.list Segment.decode))
        (Decode.field "speakers" Decode.int)


encode : SpeakerLabels -> Encode.Value
encode x =
    Encode.object
        [ ( "segments", Encode.list Segment.encode x.segments )
        , ( "speakers", Encode.int x.speakers )
        ]
