module Bartleby.View exposing (view)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Utility.List as List
import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as Decode
import Maybe.Extra as Maybe


view : Model.Model -> Browser.Document Message.Message
view model =
    { title = "Bartleby"
    , body =
        [ Html.div
            [ Attr.style "left" "0"
            , Attr.style "position" "fixed"
            , Attr.style "top" "0"
            , Attr.style "width" "20em"
            ]
            (viewSide model)
        , Html.div
            [ Attr.style "font-family" "sans-serif"
            , Attr.style "line-height" "1.5em"
            , Attr.style "margin-left" "20em"
            ]
            (viewMain model)
        ]
    }


viewSide : Model.Model -> List (Html.Html Message.Message)
viewSide model =
    let
        hasJob =
            case model.job of
                FileData.Loaded (Ok _) ->
                    True

                _ ->
                    False

        maybeChunk =
            Maybe.andThen (\index -> List.index index model.chunks) model.index

        onClick message =
            Event.onClick <|
                case model.index of
                    Nothing ->
                        Message.Ignore

                    Just index ->
                        message index

        onInput message =
            Event.onInput <|
                \string ->
                    case model.index of
                        Nothing ->
                            Message.Ignore

                        Just index ->
                            message index string
    in
    [ Html.h1 [] [ Html.text "Bartleby" ]
    , Html.ul []
        [ Html.li []
            [ Html.button
                [ Event.onClick Message.JobRequested ]
                [ Html.text "Select transcript" ]
            ]
        , Html.li []
            [ Html.button
                [ Attr.disabled (not hasJob)
                , Event.onClick Message.DownloadJob
                ]
                [ Html.text "Download transcript" ]
            ]
        ]
    , Html.ul []
        [ Html.li []
            [ Html.text "Content: "
            , Html.input
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onInput Message.UpdateContent
                , Attr.value (Maybe.unwrap "" .content maybeChunk)
                ]
                []
            ]
        , Html.li []
            [ Html.text "Confidence: "
            , Html.input
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onInput Message.UpdateConfidence
                , Attr.max "1"
                , Attr.min "0"
                , Attr.step "0.1"
                , Attr.type_ "number"
                , Attr.value <|
                    Maybe.unwrap ""
                        (\chunk -> String.fromFloat chunk.confidence)
                        maybeChunk
                ]
                []
            ]
        , Html.li []
            [ Html.text "Start: "
            , Html.input
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onInput Message.UpdateStart
                , Attr.max "1"
                , Attr.min "0"
                , Attr.step "0.1"
                , Attr.type_ "number"
                , Attr.value <|
                    Maybe.unwrap ""
                        (\chunk -> String.fromFloat chunk.start)
                        maybeChunk
                ]
                []
            ]
        , Html.li []
            [ Html.text "End: "
            , Html.input
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onInput Message.UpdateEnd
                , Attr.max "1"
                , Attr.min "0"
                , Attr.step "0.1"
                , Attr.type_ "number"
                , Attr.value <|
                    Maybe.unwrap ""
                        (\chunk -> String.fromFloat chunk.end)
                        maybeChunk
                ]
                []
            ]
        , Html.li []
            [ Html.text "Speaker: "
            , Html.input
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onInput Message.UpdateSpeaker
                , Attr.value (Maybe.withDefault "" (Maybe.andThen .speaker maybeChunk))
                ]
                []
            ]
        , Html.li []
            [ Html.button
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onClick Message.RemoveChunk
                ]
                [ Html.text "Remove word" ]
            ]
        , Html.li []
            [ Html.button
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onClick Message.SplitChunk
                ]
                [ Html.text "Split word" ]
            ]
        , Html.li []
            [ Html.button
                [ Attr.disabled (Maybe.isNothing maybeChunk)
                , onClick Message.MergeChunk
                ]
                [ Html.text "Merge word" ]
            ]
        ]
    ]


viewMain : Model.Model -> List (Html.Html Message.Message)
viewMain model =
    case model.job of
        FileData.NotAsked ->
            [ Html.p [] [ Html.text "Please select a transcript." ] ]

        FileData.Requested ->
            [ Html.p [] [ Html.text "Selecting a transcript ..." ] ]

        FileData.Selected _ ->
            [ Html.p [] [ Html.text "Loading the transcript ..." ] ]

        FileData.Loaded (Err err) ->
            [ Html.p [] [ Html.text "Failed to load transcript!" ]
            , Html.pre [] [ Html.text (Decode.errorToString err) ]
            ]

        FileData.Loaded (Ok _) ->
            model.chunks
                |> List.withIndex
                |> List.groupOn (\( _, chunk ) -> chunk.speaker)
                |> List.map (viewChunks model.index)


viewChunks : Maybe Int -> List ( Int, Chunk.Chunk ) -> Html.Html Message.Message
viewChunks maybeIndex chunks =
    Html.p [] (List.concatMap (viewChunk maybeIndex) chunks)


viewChunk : Maybe Int -> ( Int, Chunk.Chunk ) -> List (Html.Html Message.Message)
viewChunk maybeIndex ( index, chunk ) =
    let
        backgroundColor =
            if chunk.confidence >= 1.0 then
                "inherit"

            else if chunk.confidence >= 0.8 then
                "#ffc"

            else if chunk.confidence >= 0.6 then
                "#ff9"

            else if chunk.confidence >= 0.4 then
                "#ff6"

            else if chunk.confidence >= 0.2 then
                "#ff3"

            else
                "#ff0"

        color =
            case chunk.speaker of
                Just "spk_0" ->
                    "#090"

                Just "spk_1" ->
                    "#009"

                Just "spk_2" ->
                    "#900"

                _ ->
                    "inherit"

        textDecoration =
            if Just index == maybeIndex then
                "underline"

            else
                "inherit"
    in
    [ Html.span
        [ Event.onClick (Message.SelectIndex index)
        , Attr.style "background-color" backgroundColor
        , Attr.style "color" color
        , Attr.style "text-decoration" textDecoration
        ]
        [ Html.text chunk.content
        ]
    , Html.text " "
    ]
