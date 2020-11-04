module Bartleby.Type.Chunk exposing
    ( Chunk
    , fromResults
    , toResults
    )

import Bartleby.Type.Alternative as Alternative
import Bartleby.Type.Number as Number
import Bartleby.Type.ResultItem as ResultItem
import Bartleby.Type.Results as Results
import Bartleby.Type.Segment as Segment
import Bartleby.Type.SegmentItem as SegmentItem
import Bartleby.Type.SpeakerLabels as SpeakerLabels
import Bartleby.Type.Transcript as Transcript
import Bartleby.Type.Type as Type
import Bartleby.Utility.List as List
import Bartleby.Utility.Maybe as Maybe
import Set


{-| This is one little "chunk" of the transcript. Usually it will be a single
word, but it could include punctuation or even be a phrase.
-}
type alias Chunk =
    { confidence : Float
    , content : String
    , end : Float
    , speaker : Maybe String
    , start : Float
    }


fromResults : Results.Results -> List Chunk
fromResults results =
    fromResultItems
        (case results.speakerLabels of
            Nothing ->
                []

            Just speakerLabels ->
                List.concatMap .items speakerLabels.segments
        )
        results.items


fromResultItems : List SegmentItem.SegmentItem -> List ResultItem.ResultItem -> List Chunk
fromResultItems segmentItems resultItems =
    case resultItems of
        [] ->
            []

        [ resultItem ] ->
            Maybe.toList (fromResultItem segmentItems resultItem)

        first :: second :: rest ->
            case second.tipe of
                Type.Pronunciation ->
                    List.append
                        (Maybe.toList (fromResultItem segmentItems first))
                        (fromResultItems segmentItems (second :: rest))

                Type.Punctuation ->
                    fromResultItems
                        segmentItems
                        (combineResultItems first second :: rest)


fromResultItem : List SegmentItem.SegmentItem -> ResultItem.ResultItem -> Maybe Chunk
fromResultItem segmentItems resultItem =
    case ( resultItem.startTime, resultItem.endTime, resultItem.alternatives ) of
        ( Just start, Just end, alternative :: _ ) ->
            Just
                { confidence = Number.toFloat alternative.confidence
                , content = alternative.content
                , end = Number.toFloat end
                , speaker =
                    Maybe.map .speakerLabel
                        (List.find (contains resultItem) segmentItems)
                , start = Number.toFloat start
                }

        _ ->
            Nothing


contains : ResultItem.ResultItem -> SegmentItem.SegmentItem -> Bool
contains resultItem segmentItem =
    case ( resultItem.startTime, resultItem.endTime ) of
        ( Just resultStart, Just resultEnd ) ->
            let
                segmentStart =
                    Number.toFloat segmentItem.startTime

                segmentEnd =
                    Number.toFloat segmentItem.endTime
            in
            (segmentStart <= Number.toFloat resultStart)
                && (segmentEnd >= Number.toFloat resultEnd)

        _ ->
            False


combineResultItems : ResultItem.ResultItem -> ResultItem.ResultItem -> ResultItem.ResultItem
combineResultItems first second =
    { first
        | alternatives =
            List.map
                (\( x, y ) -> { x | content = x.content ++ y.content })
                (List.cartesianProduct first.alternatives second.alternatives)
        , endTime =
            Maybe.combineWith Number.maximum first.endTime second.endTime
        , startTime =
            Maybe.combineWith Number.minimum first.startTime second.startTime
    }


toResults : List Chunk -> Results.Results
toResults chunks =
    { items = List.map toResultItem chunks
    , speakerLabels = Just (toSpeakerLabels chunks)
    , transcripts = [ toTranscript chunks ]
    }


toResultItem : Chunk -> ResultItem.ResultItem
toResultItem chunk =
    { alternatives = [ toAlternative chunk ]
    , endTime = Just (Number.fromFloat chunk.end)
    , startTime = Just (Number.fromFloat chunk.start)
    , tipe = Type.Pronunciation
    }


toAlternative : Chunk -> Alternative.Alternative
toAlternative chunk =
    { confidence = Number.fromFloat chunk.confidence
    , content = chunk.content
    }


toSpeakerLabels : List Chunk -> SpeakerLabels.SpeakerLabels
toSpeakerLabels chunks =
    { segments = List.filterMap toSegment (List.groupOn .speaker chunks)
    , speakers = Set.size (Set.fromList (List.filterMap .speaker chunks))
    }


toSegment : List Chunk -> Maybe Segment.Segment
toSegment chunks =
    let
        maybeSpeaker =
            Maybe.andThen .speaker (List.head chunks)

        maybeStart =
            List.minimum (List.map .start chunks)

        maybeEnd =
            List.maximum (List.map .end chunks)
    in
    case ( maybeSpeaker, maybeStart, maybeEnd ) of
        ( Just speaker, Just start, Just end ) ->
            Just
                { endTime = Number.fromFloat end
                , items = List.filterMap toSegmentItem chunks
                , speakerLabel = speaker
                , startTime = Number.fromFloat start
                }

        _ ->
            Nothing


toSegmentItem : Chunk -> Maybe SegmentItem.SegmentItem
toSegmentItem chunk =
    Maybe.map
        (\speaker ->
            { endTime = Number.fromFloat chunk.end
            , speakerLabel = speaker
            , startTime = Number.fromFloat chunk.start
            }
        )
        chunk.speaker


toTranscript : List Chunk -> Transcript.Transcript
toTranscript chunks =
    { transcript = String.join " " (List.map .content chunks)
    }
