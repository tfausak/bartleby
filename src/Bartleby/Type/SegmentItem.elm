module Bartleby.Type.SegmentItem exposing
    ( SegmentItem
    , decode
    , encode
    )

import Bartleby.Type.Number as Number
import Json.Decode as Decode
import Json.Encode as Encode


type alias SegmentItem =
    { endTime : Number.Number
    , speakerLabel : String
    , startTime : Number.Number
    }


decode : Decode.Decoder SegmentItem
decode =
    Decode.map3 SegmentItem
        (Decode.field "end_time" Number.decode)
        (Decode.field "speaker_label" Decode.string)
        (Decode.field "start_time" Number.decode)


encode : SegmentItem -> Encode.Value
encode x =
    Encode.object
        [ ( "end_time", Number.encode x.endTime )
        , ( "speaker_label", Encode.string x.speakerLabel )
        , ( "end_time", Number.encode x.startTime )
        ]
