module Bartleby.Update exposing (update)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Type.Results as Results
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
                                , job = FileData.Loaded (Ok { job | results = Results.empty })
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

        Message.SplitChunk index ->
            ( { model
                | chunks = splitAt index model.chunks
                , index = Just (index + 1)
              }
            , Cmd.none
            )

        Message.UpdateConfidence index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just confidence ->
                    updateAt model index (\x -> { x | confidence = confidence })
            , Cmd.none
            )

        Message.UpdateContent index content ->
            ( updateAt model index (\x -> { x | content = content })
            , Cmd.none
            )

        Message.UpdateEnd index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just end ->
                    updateAt model index (\x -> { x | end = end })
            , Cmd.none
            )

        Message.UpdateSpeaker index speaker ->
            ( updateAt model index (\x -> { x | speaker = Just speaker })
            , Cmd.none
            )

        Message.UpdateStart index string ->
            ( case String.toFloat string of
                Nothing ->
                    model

                Just start ->
                    updateAt model index (\x -> { x | start = start })
            , Cmd.none
            )


updateAt : Model.Model -> Int -> (Chunk.Chunk -> Chunk.Chunk) -> Model.Model
updateAt model n f =
    { model | chunks = List.updateAt n f model.chunks }


splitAt : Int -> List Chunk.Chunk -> List Chunk.Chunk
splitAt index chunks =
    case chunks of
        [] ->
            []

        chunk :: rest ->
            if index == 0 then
                let
                    duration =
                        chunk.end - chunk.start

                    midpoint =
                        chunk.start + duration / 2
                in
                { chunk | end = midpoint }
                    :: { chunk | content = "?", start = midpoint }
                    :: rest

            else
                chunk :: splitAt (index - 1) rest
