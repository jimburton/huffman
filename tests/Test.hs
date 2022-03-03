{-# LANGUAGE TemplateHaskell #-}
module Main where

import Test.QuickCheck
import System.Random
import Control.Monad
import Data.List.Utils (countElem)
import Data.List       (nub)
import Data.Maybe      (fromJust)


import Huffman

instance Arbitrary a => Arbitrary (HTree a) where
  arbitrary = sized arbitrarySizedTree

arbitrarySizedTree :: Arbitrary a => Int -> Gen (HTree a)
arbitrarySizedTree 0 = do c <- arbitrary
                          i <- arbitrary
                          return (Leaf i c)
arbitrarySizedTree n | n>0 = do
                         c <- arbitrary
                         i <- arbitrary
                         oneof [return (Leaf i c),
                                liftM3 Branch arbitrary subtree subtree]
  where subtree = arbitrarySizedTree (n `div` 2)

-- * TESTS

isSorted :: Ord b => (a -> b) -> [a] -> Bool
isSorted _ []     = True
isSorted _ [x]    = True
isSorted f (x:xs) = (f x <= f (head xs)) && isSorted f xs

{- Frequency tables are properly sorted -}
prop_fTable_sorted :: String -> Bool
prop_fTable_sorted = isSorted snd . fTable

{- Frequency tables really reflect the input -}
prop_fTable_valid :: String -> Bool
prop_fTable_valid s = let t = fTable s in
  length t == length (nub s)
  && all (\c -> countElem c s == fromJust (lookup c t)) (nub s)


prop_fTable_els :: String -> Bool
prop_fTable_els xs = all (\(c, i) -> c `elem` xs) (fTable xs)

prop_fTable_els2 :: String -> Bool
prop_fTable_els2 xs = let cs = map fst $ fTable xs in
                      all (`elem` cs) xs
                      
countLeaves :: Num p => HTree a -> p
countLeaves t = case t of
                 (Branch _ l r) -> countLeaves l + countLeaves r
                 (Leaf _ _)     -> 1

prop_countNodes :: String -> Bool
prop_countNodes str = length (fTable str) == maybe 0 countLeaves (tree str)


prop_insert :: Eq a => HTree a -> SortedList (HTree a) -> Bool
prop_insert t (Sorted ts) = let ts' = insert t ts in
                              length ts + 1 == length ts'
                              && isSorted id ts'

prop_codec :: Ord a => [a] -> Bool
prop_codec s = case encode s of
  Nothing        -> null s
  Just (t, path) -> if null path
                    then length (nub s) == 1
                    else s == decode t path

return []

runTests :: IO Bool
runTests = $quickCheckAll
main :: IO Bool

main = runTests
