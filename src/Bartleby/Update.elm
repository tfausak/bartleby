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

        Message.Ignore ->
            pure model

        Message.JobLoaded string ->
            pure <|
                case Decode.decodeString Job.decode string of
                    Err err ->
                        { model | job = FileData.Loaded (Err err) }

                    Ok job ->
                        { model
                            | chunks = Chunk.fromResults job.results
                            , index = Nothing
                            , job = FileData.Loaded (Ok { job | results = Results.empty })
                        }

        Message.JobRequested ->
            ( { model | job = FileData.Requested }
            , Select.file [ "application/json" ] Message.JobSelected
            )

        Message.JobSelected file ->
            ( { model | job = FileData.Selected file }
            , Task.perform Message.JobLoaded (File.toString file)
            )

        Message.MergeChunk index ->
            pure { model | chunks = mergeAt index model.chunks }

        Message.RemoveChunk index ->
            pure { model | chunks = List.removeAt index model.chunks }

        Message.SelectIndex index ->
            pure { model | index = Just index }

        Message.SplitChunk index ->
            pure
                { model
                    | chunks = splitAt index model.chunks
                    , index = Just (index + 1)
                }

        Message.UpdateConfidence index string ->
            pure <|
                case String.toFloat string of
                    Nothing ->
                        model

                    Just confidence ->
                        updateAt model index (\chunk -> { chunk | confidence = confidence })

        Message.UpdateContent index content ->
            pure (updateAt model index (\chunk -> { chunk | content = content }))

        Message.UpdateEnd index string ->
            pure <|
                case String.toFloat string of
                    Nothing ->
                        model

                    Just end ->
                        updateAt model index (\chunk -> { chunk | end = end })

        Message.UpdateSpeaker index speaker ->
            pure <|
                updateAt model index <|
                    \chunk ->
                        { chunk
                            | speaker =
                                if String.isEmpty speaker then
                                    Nothing

                                else
                                    Just speaker
                        }

        Message.UpdateStart index string ->
            pure <|
                case String.toFloat string of
                    Nothing ->
                        model

                    Just start ->
                        updateAt model index (\chunk -> { chunk | start = start })


pure : model -> ( model, Cmd.Cmd message )
pure model =
    ( model, Cmd.none )


mergeAt : Int -> List Chunk.Chunk -> List Chunk.Chunk
mergeAt index chunks =
    case chunks of
        first :: second :: rest ->
            if index == 0 then
                { first
                    | content = first.content ++ " " ++ second.content
                    , end = second.end
                }
                    :: rest

            else
                first :: mergeAt (index - 1) (second :: rest)

        _ ->
            chunks


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
