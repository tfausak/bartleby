module Bartleby.Type.ResultItem exposing (ResultItem, decode, encode)

import Bartleby.Type.Alternative as Alternative
import Bartleby.Type.Number as Number
import Bartleby.Type.Type as Type
import Bartleby.Utility as Utility
import Json.Decode as Decode
import Json.Encode as Encode


type alias ResultItem =
    { alternatives : List Alternative.Alternative
    , endTime : Maybe Number.Number
    , startTime : Maybe Number.Number
    , tipe : Type.Type
    }


decode : Decode.Decoder ResultItem
decode =
    Decode.map4 ResultItem
        (Decode.field "alternatives" (Decode.list Alternative.decode))
        (Decode.maybe (Decode.field "end_time" Number.decode))
        (Decode.maybe (Decode.field "start_time" Number.decode))
        (Decode.field "type" Type.decode)


encode : ResultItem -> Encode.Value
encode resultItem =
    Encode.object
        [ ( "alternatives", Encode.list Alternative.encode resultItem.alternatives )
        , ( "end_time", Utility.encodeMaybe Number.encode resultItem.endTime )
        , ( "start_time", Utility.encodeMaybe Number.encode resultItem.startTime )
        , ( "type", Type.encode resultItem.tipe )
        ]
