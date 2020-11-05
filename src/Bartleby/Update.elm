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

        Message.RemoveChunk index ->
            ( { model
                | chunks = List.removeAt index model.chunks
                , index = Nothing
              }
            , Cmd.none
            )

        Message.SelectIndex index ->
            ( { model | index = Just index }
            , Cmd.none
            )

        Message.UpdateConfidence index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just confidence ->
                    { model
                        | chunks =
                            List.updateAt index
                                (\chunk -> { chunk | confidence = confidence })
                                model.chunks
                    }
            , Cmd.none
            )

        Message.UpdateContent index content ->
            ( { model
                | chunks =
                    List.updateAt index
                        (\chunk -> { chunk | content = content })
                        model.chunks
              }
            , Cmd.none
            )

        Message.UpdateEnd index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just end ->
                    { model
                        | chunks =
                            List.updateAt index
                                (\chunk -> { chunk | end = end })
                                model.chunks
                    }
            , Cmd.none
            )

        Message.UpdateSpeaker index speaker ->
            ( { model
                | chunks =
                    List.updateAt index
                        (\chunk -> { chunk | speaker = Just speaker })
                        model.chunks
              }
            , Cmd.none
            )

        Message.UpdateStart index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just start ->
                    { model
                        | chunks =
                            List.updateAt index
                                (\chunk -> { chunk | start = start })
                                model.chunks
                    }
            , Cmd.none
            )
