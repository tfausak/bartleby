module Bartleby.Type.Type exposing (Type(..), decode, encode)

import Json.Decode as Decode
import Json.Encode as Encode


type Type
    = Pronunciation
    | Punctuation


decode : Decode.Decoder Type
decode =
    Decode.andThen
        (\string ->
            case string of
                "pronunciation" ->
                    Decode.succeed Pronunciation

                "punctuation" ->
                    Decode.succeed Punctuation

                _ ->
                    Decode.fail ("unknown type: " ++ string)
        )
        Decode.string


encode : Type -> Encode.Value
encode tipe =
    case tipe of
        Pronunciation ->
            Encode.string "pronunciation"

        Punctuation ->
            Encode.string "punctuation"
