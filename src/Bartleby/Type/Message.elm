module Bartleby.Type.Message exposing (Message(..))

import File


type Message
    = DoNothing
    | DownloadJob
    | JobLoaded String
    | JobRequested
    | JobSelected File.File
