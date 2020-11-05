module Bartleby.Utility.Maybe exposing
    ( combineWith
    , isJust
    , isNothing
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


isJust : Maybe a -> Bool
isJust m =
    not (isNothing m)


isNothing : Maybe a -> Bool
isNothing =
    maybe True (always False)


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
