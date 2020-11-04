module Bartleby.Type.Job exposing
    ( Job
    , decode
    , encode
    )

import Bartleby.Type.Results as Results
import Bartleby.Type.Status as Status
import Json.Decode as Decode
import Json.Encode as Encode


type alias Job =
    { accountId : String
    , jobName : String
    , results : Results.Results
    , status : Status.Status
    }


decode : Decode.Decoder Job
decode =
    Decode.map4 Job
        (Decode.field "accountId" Decode.string)
        (Decode.field "jobName" Decode.string)
        (Decode.field "results" Results.decode)
        (Decode.field "status" Status.decode)


encode : Job -> Encode.Value
encode x =
    Encode.object
        [ ( "accountId", Encode.string x.accountId )
        , ( "jobName", Encode.string x.jobName )
        , ( "results", Results.encode x.results )
        , ( "status", Status.encode x.status )
        ]
