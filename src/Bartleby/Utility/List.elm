module Bartleby.Utility.List exposing
    ( cartesianProduct
    , dropWhile
    , find
    , group
    , groupBy
    , groupOn
    , index
    , removeAt
    , span
    , takeWhile
    , updateAt
    , withIndex
    )


cartesianProduct : List a -> List b -> List ( a, b )
cartesianProduct xs ys =
    List.concatMap (\x -> List.map (\y -> ( x, y )) ys) xs


dropWhile : (a -> Bool) -> List a -> List a
dropWhile f xs =
    case xs of
        [] ->
            []

        x :: ys ->
            if f x then
                dropWhile f ys

            else
                ys


find : (a -> Bool) -> List a -> Maybe a
find f xs =
    case xs of
        [] ->
            Nothing

        x :: ys ->
            if f x then
                Just x

            else
                find f ys


group : List a -> List (List a)
group =
    groupOn identity


groupBy : (a -> a -> Bool) -> List a -> List (List a)
groupBy f xs =
    case xs of
        [] ->
            []

        x :: ys ->
            let
                ( before, after ) =
                    span (f x) ys
            in
            (x :: before) :: groupBy f after


groupOn : (a -> b) -> List a -> List (List a)
groupOn f =
    groupBy (\x y -> f x == f y)


index : Int -> List a -> Maybe a
index n xs =
    case xs of
        [] ->
            Nothing

        x :: ys ->
            if n == 0 then
                Just x

            else
                index (n - 1) ys


removeAt : Int -> List a -> List a
removeAt n xs =
    case xs of
        [] ->
            []

        x :: ys ->
            if n == 0 then
                ys

            else
                x :: removeAt (n - 1) ys


span : (a -> Bool) -> List a -> ( List a, List a )
span f xs =
    ( takeWhile f xs, dropWhile f xs )


takeWhile : (a -> Bool) -> List a -> List a
takeWhile f xs =
    case xs of
        [] ->
            []

        x :: ys ->
            if f x then
                x :: takeWhile f ys

            else
                []


updateAt : Int -> (a -> a) -> List a -> List a
updateAt n f xs =
    case xs of
        [] ->
            []

        x :: ys ->
            if n == 0 then
                f x :: ys

            else
                x :: updateAt (n - 1) f ys


withIndex : List a -> List ( Int, a )
withIndex =
    List.indexedMap Tuple.pair
