module Bartleby.View exposing (view)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
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
            , Html.button
                [ case model.job of
                    FileData.Loaded (Ok _) ->
                        Html.onClick Message.DownloadJob

                    _ ->
                        Attr.disabled True
                ]
                [ Html.text "Download transcript" ]
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
                    Html.p
                        [ Attr.style "font-family" "sans-serif"
                        , Attr.style "line-height" "1.5em"
                        , Attr.style "padding" "1.5em"
                        ]
                        (List.concatMap viewChunk model.chunks)


viewChunk : Chunk.Chunk -> List (Html.Html Message.Message)
viewChunk chunk =
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
        [ Attr.style "background-color" backgroundColor
        , Attr.style "color" color
        , Attr.title <|
            String.join " "
                [ "confidence:"
                , String.fromFloat chunk.confidence
                , "start:"
                , String.fromFloat chunk.start
                , "end:"
                , String.fromFloat chunk.end
                , "speaker:"
                , Maybe.withDefault "unknown" chunk.speaker
                ]
        ]
        [ Html.text chunk.content ]
    , Html.text " "
    ]
