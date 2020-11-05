module Bartleby.Utility.Maybe exposing
    ( combineWith
    , isJust
    , isNothing
    , maybe
    , toList
    )

import Maybe.Extra as Extra


combineWith : (a -> a -> a) -> Maybe a -> Maybe a -> Maybe a
combineWith f mx my =
    case ( mx, my ) of
        ( Just x, Just y ) ->
            Just (f x y)

        ( Just x, Nothing ) ->
            Just x

        ( Nothing, Just y ) ->
            Just y

        ( Nothing, Nothing ) ->
            Nothing


isJust : Maybe a -> Bool
isJust =
    Extra.isJust


isNothing : Maybe a -> Bool
isNothing =
    Extra.isNothing


maybe : b -> (a -> b) -> Maybe a -> b
maybe =
    Extra.unwrap


toList : Maybe a -> List a
toList =
    Extra.toList
