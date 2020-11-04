module Bartleby.Type.Segment exposing (Segment, decode, encode)

import Bartleby.Type.Number as Number
import Bartleby.Type.SegmentItem as SegmentItem
import Json.Decode as Decode
import Json.Encode as Encode


{-| You can think of this as a block of speech by a single speaker. The items
contained within give more details about individual words.

The speaker label is usually a string like `"spk_N"`, where "N" is a number
starting from 0. So if you have two speakers, they are probably `"spk_0"` and
`"spk_1"`.
-}
type alias Segment =
    { endTime : Number.Number
    , items : List SegmentItem.SegmentItem
    , speakerLabel : String
    , startTime : Number.Number
    }


decode : Decode.Decoder Segment
decode =
    Decode.map4 Segment
        (Decode.field "end_time" Number.decode)
        (Decode.field "items" (Decode.list SegmentItem.decode))
        (Decode.field "speaker_label" Decode.string)
        (Decode.field "start_time" Number.decode)


encode : Segment -> Encode.Value
encode segment =
    Encode.object
        [ ( "end_time", Number.encode segment.endTime )
        , ( "items", Encode.list SegmentItem.encode segment.items )
        , ( "speaker_label", Encode.string segment.speakerLabel )
        , ( "end_time", Number.encode segment.startTime )
        ]
