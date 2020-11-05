module Bartleby.View exposing (view)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Utility.List as List
import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Html
import Json.Decode as Decode


view : Model.Model -> Browser.Document Message.Message
view model =
    { title = "Bartleby"
    , body =
        [ Html.h1 [] [ Html.text "Bartleby" ]
        , Html.div []
            [ Html.button [ Html.onClick Message.JobRequested ]
                [ Html.text "Select transcript" ]
            ]
        , viewJob model
        ]
    }


viewJob : Model.Model -> Html.Html Message.Message
viewJob model =
    case model.job of
        FileData.NotAsked ->
            Html.p [] [ Html.text "Click the button." ]

        FileData.Requested ->
            Html.p [] [ Html.text "Selecting a file ..." ]

        FileData.Selected _ ->
            Html.p [] [ Html.text "Loading the file ..." ]

        FileData.Loaded result ->
            case result of
                Err err ->
                    Html.div []
                        [ Html.p [] [ Html.text "Failed to parse transcript!" ]
                        , Html.pre [] [ Html.text (Decode.errorToString err) ]
                        ]

                Ok _ ->
                    Html.div []
                        [ Html.button [ Html.onClick Message.DownloadJob ]
                            [ Html.text "Download transcript" ]
                        , Html.div [] <|
                            case model.index of
                                Nothing ->
                                    [ Html.text "Click on a word." ]

                                Just index ->
                                    case List.index index model.chunks of
                                        Nothing ->
                                            [ Html.text "Chunk not found!" ]

                                        Just chunk ->
                                            [ Html.text "content: "
                                            , Html.input
                                                [ Html.onInput (Message.UpdateContent index)
                                                , Attr.value chunk.content
                                                ]
                                                []
                                            , Html.text " confidence: "
                                            , Html.input
                                                [ Html.onInput (Message.UpdateConfidence index)
                                                , Attr.max "1"
                                                , Attr.min "0"
                                                , Attr.step "0.1"
                                                , Attr.style "width" "5em"
                                                , Attr.type_ "number"
                                                , Attr.value (String.fromFloat chunk.confidence)
                                                ]
                                                []
                                            , Html.text " start: "
                                            , Html.input
                                                [ Html.onInput (Message.UpdateStart index)
                                                , Attr.min "0"
                                                , Attr.step "0.1"
                                                , Attr.style "width" "5em"
                                                , Attr.type_ "number"
                                                , Attr.value (String.fromFloat chunk.start)
                                                ]
                                                []
                                            , Html.text " end: "
                                            , Html.input
                                                [ Html.onInput (Message.UpdateEnd index)
                                                , Attr.min "0"
                                                , Attr.step "0.1"
                                                , Attr.style "width" "5em"
                                                , Attr.type_ "number"
                                                , Attr.value (String.fromFloat chunk.end)
                                                ]
                                                []
                                            , Html.text " speaker: "
                                            , Html.input
                                                [ Html.onInput (Message.UpdateSpeaker index)
                                                , Attr.value (Maybe.withDefault "unknown" chunk.speaker)
                                                ]
                                                []
                                            , Html.text " "
                                            , Html.button
                                                [ Html.onClick (Message.RemoveChunk index) ]
                                                [ Html.text "Remove" ]
                                            , Html.text " "
                                            , Html.button
                                                [ Html.onClick (Message.SplitChunk index) ]
                                                [ Html.text "Split" ]
                                            ]
                        , Html.p
                            [ Attr.style "font-family" "sans-serif"
                            , Attr.style "line-height" "1.5em"
                            , Attr.style "padding" "0 1.5em 3em 1.5em"
                            ]
                            (List.concat (List.indexedMap viewChunk model.chunks))
                        ]


viewChunk : Int -> Chunk.Chunk -> List (Html.Html Message.Message)
viewChunk index chunk =
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
    in
    [ Html.span
        [ Html.onClick (Message.SelectIndex index)
        , Attr.style "background-color" backgroundColor
        , Attr.style "color" color
        ]
        [ Html.text chunk.content ]
    , Html.text " "
    ]
