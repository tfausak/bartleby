module Bartleby.Type.Results exposing
    ( Results
    , decode
    , empty
    , encode
    )

import Bartleby.Type.ResultItem as ResultItem
import Bartleby.Type.SpeakerLabels as SpeakerLabels
import Bartleby.Type.Transcript as Transcript
import Bartleby.Utility.Encode as Encode
import Json.Decode as Decode
import Json.Encode as Encode


{-| This has a list of transcripts, but that list usually only has one
transcript in it.
-}
type alias Results =
    { items : List ResultItem.ResultItem
    , speakerLabels : Maybe SpeakerLabels.SpeakerLabels
    , transcripts : List Transcript.Transcript
    }


empty : Results
empty =
    { items = []
    , speakerLabels = Nothing
    , transcripts = []
    }


decode : Decode.Decoder Results
decode =
    Decode.map3 Results
        (Decode.field "items" (Decode.list ResultItem.decode))
        (Decode.maybe (Decode.field "speaker_labels" SpeakerLabels.decode))
        (Decode.field "transcripts" (Decode.list Transcript.decode))


encode : Results -> Encode.Value
encode x =
    Encode.object
        [ ( "items", Encode.list ResultItem.encode x.items )
        , ( "speaker_labels", Encode.maybe SpeakerLabels.encode x.speakerLabels )
        , ( "transcripts", Encode.list Transcript.encode x.transcripts )
        ]
