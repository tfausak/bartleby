module Bartleby.Type.Message exposing (Message(..))

import File


type Message
    = DoNothing
    | DownloadJob
    | JobLoaded String
    | JobRequested
    | JobSelected File.File
    | RemoveChunk Int
    | SelectIndex Int
    | UpdateConfidence Int String
    | UpdateContent Int String
    | UpdateEnd Int String
    | UpdateSpeaker Int String
    | UpdateStart Int String
