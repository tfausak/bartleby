module Bartleby.Type.Job exposing (Job, decode, encode)

import Bartleby.Type.Number as Number
import Bartleby.Type.Results as Results
import Bartleby.Type.Status as Status
import Json.Decode as Decode
import Json.Encode as Encode


type alias Job =
    { accountId : Number.Number
    , jobName : String
    , results : Results.Results
    , status : Status.Status
    }


decode : Decode.Decoder Job
decode =
    Decode.map4 Job
        (Decode.field "accountId" Number.decode)
        (Decode.field "jobName" Decode.string)
        (Decode.field "results" Results.decode)
        (Decode.field "status" Status.decode)


encode : Job -> Encode.Value
encode job =
    Encode.object
        [ ( "accountId", Number.encode job.accountId )
        , ( "jobName", Encode.string job.jobName )
        , ( "results", Results.encode job.results )
        , ( "status", Status.encode job.status )
        ]