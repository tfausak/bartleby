module Bartleby.Type.Type exposing (Type(..), decode, encode, fromString, toString)

import Json.Decode as Decode
import Json.Encode as Encode


type Type
    = Pronunciation
    | Punctuation


fromString : String -> Maybe Type
fromString string =
    case string of
        "pronunciation" ->
            Just Pronunciation

        "punctuation" ->
            Just Punctuation

        _ ->
            Nothing


toString : Type -> String
toString tipe =
    case tipe of
        Pronunciation ->
            "pronunciation"

        Punctuation ->
            "punctuation"


decode : Decode.Decoder Type
decode =
    Decode.andThen
        (\string ->
            case fromString string of
                Just tipe ->
                    Decode.succeed tipe

                Nothing ->
                    Decode.fail ("unknown type: " ++ string)
        )
        Decode.string


encode : Type -> Encode.Value
encode tipe =
    Encode.string (toString tipe)
