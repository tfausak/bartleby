module Bartleby.Type.FileData exposing (FileData(..))

import File


type FileData value
    = NotAsked
    | Requested
    | Selected File.File
    | Loaded value
