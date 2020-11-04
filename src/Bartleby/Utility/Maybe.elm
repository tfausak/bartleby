module Bartleby.Utility.Maybe exposing
    ( combineWith
    , maybe
    , toList
    )


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


maybe : b -> (a -> b) -> Maybe a -> b
maybe d f m =
    case m of
        Nothing ->
            d

        Just x ->
            f x


toList : Maybe a -> List a
toList =
    maybe [] List.singleton
