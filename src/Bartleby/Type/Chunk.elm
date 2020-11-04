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
import Bartleby.Utility as Utility
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
            Utility.maybeToList (fromResultItem segmentItems resultItem)

        first :: second :: rest ->
            case second.tipe of
                Type.Pronunciation ->
                    List.append
                        (Utility.maybeToList (fromResultItem segmentItems first))
                        (fromResultItems segmentItems (second :: rest))

                Type.Punctuation ->
                    fromResultItems
                        segmentItems
                        (combineResultItems first second :: rest)


combineResultItems : ResultItem.ResultItem -> ResultItem.ResultItem -> ResultItem.ResultItem
combineResultItems first second =
    { first
        | alternatives =
            List.map
                (\( x, y ) -> { x | content = x.content ++ y.content })
                (cartesianProduct first.alternatives second.alternatives)
        , endTime =
            combineMaybes Number.maximum first.endTime second.endTime
        , startTime =
            combineMaybes Number.minimum first.startTime second.startTime
    }


fromResultItem : List SegmentItem.SegmentItem -> ResultItem.ResultItem -> Maybe Chunk
fromResultItem segmentItems resultItem =
    case resultItem.alternatives of
        [] ->
            Nothing

        alternative :: _ ->
            Just
                { confidence = Number.toFloat alternative.confidence
                , content = alternative.content
                , end = Utility.maybe 0 Number.toFloat resultItem.endTime
                , speaker =
                    List.foldl
                        (\x m ->
                            case m of
                                Just _ ->
                                    m

                                Nothing ->
                                    if contains x resultItem then
                                        Just x.speakerLabel

                                    else
                                        Nothing
                        )
                        Nothing
                        segmentItems
                , start = Utility.maybe 0 Number.toFloat resultItem.startTime
                }


contains : SegmentItem.SegmentItem -> ResultItem.ResultItem -> Bool
contains s r =
    let
        s0 =
            Number.toFloat s.startTime

        s1 =
            Number.toFloat s.endTime

        r0 =
            Utility.maybe -1 Number.toFloat r.startTime

        r1 =
            Utility.maybe 9999 Number.toFloat r.endTime
    in
    s0 <= r0 && s1 >= r1


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
    { segments = List.filterMap toSegment chunks
    , speakers = Set.size (Set.fromList (List.filterMap .speaker chunks))
    }


toSegment : Chunk -> Maybe Segment.Segment
toSegment chunk =
    Maybe.map
        (\speaker ->
            { endTime = Number.fromFloat chunk.end
            , items = Utility.maybeToList (toSegmentItem chunk)
            , speakerLabel = speaker
            , startTime = Number.fromFloat chunk.start
            }
        )
        chunk.speaker


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


cartesianProduct : List a -> List b -> List ( a, b )
cartesianProduct xs ys =
    List.concatMap (\x -> List.map (\y -> ( x, y )) ys) xs


combineMaybes : (a -> a -> a) -> Maybe a -> Maybe a -> Maybe a
combineMaybes f mx my =
    case ( mx, my ) of
        ( Just x, Just y ) ->
            Just (f x y)

        ( Just x, Nothing ) ->
            Just x

        ( Nothing, Just y ) ->
            Just y

        ( Nothing, Nothing ) ->
            Nothing
