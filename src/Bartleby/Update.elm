module Bartleby.Update exposing (update)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Utility.List as List
import File
import File.Download as Download
import File.Select as Select
import Json.Decode as Decode
import Json.Encode as Encode
import Task


update : Message.Message -> Model.Model -> ( Model.Model, Cmd Message.Message )
update message model =
    case message of
        Message.DoNothing ->
            ( model
            , Cmd.none
            )

        Message.DownloadJob ->
            ( model
            , case model.job of
                FileData.Loaded (Ok job) ->
                    { job | results = Chunk.toResults model.chunks }
                        |> Job.encode
                        |> Encode.encode 2
                        |> Download.string
                            (job.jobName ++ ".json")
                            "application/json"

                _ ->
                    Cmd.none
            )

        Message.JobLoaded string ->
            let
                newModel =
                    case Decode.decodeString Job.decode string of
                        Err err ->
                            { model | job = FileData.Loaded (Err err) }

                        Ok job ->
                            { model
                                | chunks = Chunk.fromResults job.results
                                , index = Nothing
                                , job = FileData.Loaded (Ok job)
                            }
            in
            ( newModel, Cmd.none )

        Message.JobRequested ->
            ( { model | job = FileData.Requested }
            , Select.file [ "application/json" ] Message.JobSelected
            )

        Message.JobSelected file ->
            ( { model | job = FileData.Selected file }
            , Task.perform Message.JobLoaded (File.toString file)
            )

        Message.SelectIndex index ->
            ( { model | index = Just index }
            , Cmd.none
            )

        Message.UpdateConfidence string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just confidence ->
                    case model.index of
                        Nothing ->
                            model

                        Just index ->
                            { model
                                | chunks =
                                    List.updateAt index
                                        (\x -> { x | confidence = confidence })
                                        model.chunks
                            }
            , Cmd.none
            )

        Message.UpdateContent content ->
            ( case model.index of
                Nothing ->
                    model

                Just index ->
                    { model
                        | chunks =
                            List.updateAt index
                                (\chunk -> { chunk | content = content })
                                model.chunks
                    }
            , Cmd.none
            )

        Message.UpdateEnd string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just end ->
                    case model.index of
                        Nothing ->
                            model

                        Just index ->
                            { model
                                | chunks =
                                    List.updateAt index
                                        (\x -> { x | end = end })
                                        model.chunks
                            }
            , Cmd.none
            )

        Message.UpdateSpeaker speaker ->
            ( case model.index of
                Nothing ->
                    model

                Just index ->
                    { model
                        | chunks =
                            List.updateAt index
                                (\chunk -> { chunk | speaker = Just speaker })
                                model.chunks
                    }
            , Cmd.none
            )

        Message.UpdateStart string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just start ->
                    case model.index of
                        Nothing ->
                            model

                        Just index ->
                            { model
                                | chunks =
                                    List.updateAt index
                                        (\x -> { x | start = start })
                                        model.chunks
                            }
            , Cmd.none
            )
