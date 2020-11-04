module Bartleby.View exposing (view)

import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Type.Number as Number
import Bartleby.Type.ResultItem as ResultItem
import Bartleby.Type.Type as Type
import Bartleby.Utility as Utility
import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Html


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
        , viewJob model.job
        ]
    }


viewJob : FileData.FileData (Result x Job.Job) -> Html.Html Message.Message
viewJob fileData =
    case fileData of
        FileData.NotAsked ->
            Html.p [] [ Html.text "Click the button." ]

        FileData.Requested ->
            Html.p [] [ Html.text "Selecting a file ..." ]

        FileData.Selected _ ->
            Html.p [] [ Html.text "Loading the file ..." ]

        FileData.Loaded result ->
            case result of
                Err _ ->
                    Html.p []
                        [ Html.text "Failed to parse transcript!" ]

                Ok job ->
                    Html.p
                        [ Attr.style "font-family" "sans-serif"
                        , Attr.style "line-height" "1.5em"
                        , Attr.style "padding" "1.5em"
                        ]
                        (List.concatMap viewResultItem job.results.items)


viewResultItem : ResultItem.ResultItem -> List (Html.Html Message.Message)
viewResultItem resultItem =
    case List.head resultItem.alternatives of
        Nothing ->
            []

        Just alternative ->
            let
                confidence =
                    alternative.confidence
                        |> Number.toFloat
                        |> (\float -> float * 100)
                        |> round

                backgroundColor =
                    if confidence >= 100 || resultItem.tipe == Type.Punctuation then
                        "inherit"

                    else if confidence >= 80 then
                        "#fcc"

                    else if confidence >= 60 then
                        "#f99"

                    else if confidence >= 40 then
                        "#f66"

                    else if confidence >= 20 then
                        "#f33"

                    else
                        "#f00"

                content =
                    Html.span
                        [ Attr.style "background-color" backgroundColor
                        , Attr.title <|
                            String.join " "
                                [ "type:"
                                , Type.toString resultItem.tipe
                                , "confidence:"
                                , String.fromInt confidence
                                , "start:"
                                , String.fromFloat (Utility.maybe 0 Number.toFloat resultItem.startTime)
                                , "end:"
                                , String.fromFloat (Utility.maybe 0 Number.toFloat resultItem.endTime)
                                ]
                        ]
                        [ Html.text alternative.content ]
            in
            case resultItem.tipe of
                Type.Pronunciation ->
                    [ Html.text " ", content ]

                Type.Punctuation ->
                    [ content ]
