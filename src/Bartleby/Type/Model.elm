module Bartleby.Type.Model exposing (Model)

import Bartleby.Type.Chunk as Chunk
import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Json.Decode as Decode


{-| It is expected that all the real data is held in the chunks. If the job has
been successfully loaded, the chunks should be non-empty. The job is kept
around for its metadata.
-}
type alias Model =
    { chunks : List Chunk.Chunk
    , index : Maybe Int
    , job : FileData.FileData (Result Decode.Error Job.Job)
    }
