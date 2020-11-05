module Bartleby.Type.Message exposing (Message(..))

import File


type Message
    = DoNothing
    | DownloadJob
    | JobLoaded String
    | JobRequested
    | JobSelected File.File
    | SelectIndex Int
    | UpdateConfidence String
    | UpdateContent String
    | UpdateEnd String
    | UpdateSpeaker String
    | UpdateStart String
