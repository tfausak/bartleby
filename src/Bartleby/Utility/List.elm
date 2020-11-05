module Bartleby.Utility.List exposing
    ( cartesianSquare
    , groupOn
    , withIndex
    )

import Basics.Extra as Basics
import List.Extra as List


cartesianSquare : List a -> List b -> List ( a, b )
cartesianSquare xs ys =
    List.concatMap (\x -> List.map (\y -> ( x, y )) ys) xs


groupOn : (a -> b) -> List a -> List (List a)
groupOn f xs =
    List.map (Basics.uncurry (::)) (List.groupWhile (on (==) f) xs)


on : (b -> b -> c) -> (a -> b) -> a -> a -> c
on g f x y =
    g (f x) (f y)


withIndex : List a -> List ( Int, a )
withIndex =
    List.indexedMap Tuple.pair
