module Bartleby.Type.Model exposing (Model)

import Bartleby.Type.FileData as FileData
import Bartleby.Type.Job as Job
import Json.Decode as Decode


type alias Model =
    { job : FileData.FileData (Result Decode.Error Job.Job)
    }
