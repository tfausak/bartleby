module Bartleby.Type.Status exposing (Status(..), decode, encode, fromString, toString)

import Json.Decode as Decode
import Json.Encode as Encode


type Status
    = Completed


fromString : String -> Maybe Status
fromString string =
    case string of
        "COMPLETED" ->
            Just Completed

        _ ->
            Nothing


toString : Status -> String
toString status =
    case status of
        Completed ->
            "COMPLETED"


decode : Decode.Decoder Status
decode =
    Decode.andThen
        (\string ->
            case fromString string of
                Just status ->
                    Decode.succeed status

                Nothing ->
                    Decode.fail ("unknown status: " ++ string)
        )
        Decode.string


encode : Status -> Encode.Value
encode status =
    Encode.string (toString status)
