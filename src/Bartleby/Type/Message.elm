module Bartleby.Type.Message exposing (Message(..))

import File


type Message
    = DoNothing
    | DownloadJob
    | JobLoaded String
    | JobRequested
    | JobSelected File.File
    | MergeChunk Int
    | RemoveChunk Int
    | SelectIndex Int
    | SplitChunk Int
    | UpdateConfidence Int String
    | UpdateContent Int String
    | UpdateEnd Int String
    | UpdateSpeaker Int String
    | UpdateStart Int String
