module Bartleby.Type.FileData exposing (FileData(..))

import File


type FileData a
    = NotAsked
    | Requested
    | Selected File.File
    | Loaded a
