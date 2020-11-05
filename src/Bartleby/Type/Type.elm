module Bartleby.Type.Type exposing
    ( Type(..)
    , decode
    , encode
    , fromString
    , toString
    )

import Json.Decode as Decode
import Json.Encode as Encode


type Type
    = Pronunciation
    | Punctuation


fromString : String -> Maybe Type
fromString x =
    case x of
        "pronunciation" ->
            Just Pronunciation

        "punctuation" ->
            Just Punctuation

        _ ->
            Nothing


toString : Type -> String
toString x =
    case x of
        Pronunciation ->
            "pronunciation"

        Punctuation ->
            "punctuation"


decode : Decode.Decoder Type
decode =
    Decode.andThen
        (\string ->
            case fromString string of
                Just type_ ->
                    Decode.succeed type_

                Nothing ->
                    Decode.fail ("unknown type: " ++ string)
        )
        Decode.string


encode : Type -> Encode.Value
encode x =
    Encode.string (toString x)
