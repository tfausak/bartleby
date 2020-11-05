module Bartleby.Type.ResultItem exposing
    ( ResultItem
    , decode
    , encode
    )

import Bartleby.Type.Alternative as Alternative
import Bartleby.Type.Number as Number
import Bartleby.Type.Type as Type
import Bartleby.Utility.Encode as Encode
import Json.Decode as Decode
import Json.Encode as Encode


type alias ResultItem =
    { alternatives : List Alternative.Alternative
    , endTime : Maybe Number.Number
    , startTime : Maybe Number.Number
    , type_ : Type.Type
    }


decode : Decode.Decoder ResultItem
decode =
    Decode.map4 ResultItem
        (Decode.field "alternatives" (Decode.list Alternative.decode))
        (Decode.maybe (Decode.field "end_time" Number.decode))
        (Decode.maybe (Decode.field "start_time" Number.decode))
        (Decode.field "type" Type.decode)


encode : ResultItem -> Encode.Value
encode x =
    Encode.object
        [ ( "alternatives", Encode.list Alternative.encode x.alternatives )
        , ( "end_time", Encode.maybe Number.encode x.endTime )
        , ( "start_time", Encode.maybe Number.encode x.startTime )
        , ( "type", Type.encode x.type_ )
        ]
