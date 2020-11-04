module Bartleby.Type.Results exposing (Results, decode, encode)

import Bartleby.Type.ResultItem as ResultItem
import Bartleby.Type.SpeakerLabels as SpeakerLabels
import Bartleby.Type.Transcript as Transcript
import Bartleby.Utility as Utility
import Json.Decode as Decode
import Json.Encode as Encode


{-| This has a list of transcripts, but that list usually only has one transcript
in it.
-}
type alias Results =
    { items : List ResultItem.ResultItem
    , speakerLabels : Maybe SpeakerLabels.SpeakerLabels
    , transcripts : List Transcript.Transcript
    }


decode : Decode.Decoder Results
decode =
    Decode.map3 Results
        (Decode.field "items" (Decode.list ResultItem.decode))
        (Decode.maybe (Decode.field "speaker_labels" SpeakerLabels.decode))
        (Decode.field "transcripts" (Decode.list Transcript.decode))


encode : Results -> Encode.Value
encode results =
    Encode.object
        [ ( "items", Encode.list ResultItem.encode results.items )
        , ( "speakerLabels", Utility.encodeMaybe SpeakerLabels.encode results.speakerLabels )
        , ( "transcripts", Encode.list Transcript.encode results.transcripts )
        ]
