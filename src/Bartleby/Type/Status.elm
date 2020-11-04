module Bartleby.Type.Status exposing (Status(..), decode, encode)

import Json.Decode as Decode
import Json.Encode as Encode


type Status
    = Completed


decode : Decode.Decoder Status
decode =
    Decode.andThen
        (\string ->
            case string of
                "COMPLETED" ->
                    Decode.succeed Completed

                _ ->
                    Decode.fail ("unknown status: " ++ string)
        )
        Decode.string


encode : Status -> Encode.Value
encode status =
    case status of
        Completed ->
            Encode.string "COMPLETED"
