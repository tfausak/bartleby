module Bartleby.Utility.List exposing
    ( cartesianProduct
    , find
    , groupOn
    , index
    , removeAt
    , updateAt
    , withIndex
    )

import List.Extra as Extra


cartesianProduct : List a -> List b -> List ( a, b )
cartesianProduct xs ys =
    List.concatMap (\x -> List.map (\y -> ( x, y )) ys) xs


find : (a -> Bool) -> List a -> Maybe a
find =
    Extra.find


groupOn : (a -> b) -> List a -> List (List a)
groupOn f xs =
    xs
        |> Extra.groupWhile (\x y -> f x == f y)
        |> List.map (\( h, t ) -> h :: t)


index : Int -> List a -> Maybe a
index =
    Extra.getAt


removeAt : Int -> List a -> List a
removeAt =
    Extra.removeAt


updateAt : Int -> (a -> a) -> List a -> List a
updateAt =
    Extra.updateAt


withIndex : List a -> List ( Int, a )
withIndex =
    List.indexedMap Tuple.pair
