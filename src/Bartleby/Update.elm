module Bartleby.Update exposing (update)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
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
