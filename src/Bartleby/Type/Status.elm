module Bartleby.Type.Status exposing
    ( Status(..)
    , decode
    , encode
    , fromString
    , toString
    )

import Json.Decode as Decode
import Json.Encode as Encode


type Status
    = Completed


fromString : String -> Maybe Status
fromString x =
    case x of
        "COMPLETED" ->
            Just Completed

        _ ->
            Nothing


toString : Status -> String
toString x =
    case x of
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
encode x =
    Encode.string (toString x)
