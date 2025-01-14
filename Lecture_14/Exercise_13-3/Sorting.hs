{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}

{-
Gianni Monteban & Martijn Vogelaar
1047546 & 1047391
-}

module Sorting
where
import Squiggol

data Tree elem  =  Empty | Node (Tree elem) elem (Tree elem)
   deriving Show

data TREE elem tree  =  EMPTY | NODE tree elem tree
   deriving Show
   
instance Functor (TREE elem) where
  fmap _f  (EMPTY)       =  EMPTY
  fmap f   (NODE l a r)  =  NODE (f l) a (f r)

instance Base (TREE elem) where
  type Rec (TREE elem) = Tree elem
  inn (EMPTY)       =  Empty
  inn (NODE l a r)  =  Node l a r
  out (Empty)       =  EMPTY
  out (Node l a r)  =  NODE l a r

-- Growing a search tree.

grow1, grow2 :: (Ord elem) => [elem] -> Tree elem
grow1  =  unfold  (para  (fmap (joinRight inn) . growCore))
grow2  =  fold    (apo   (growCore . fmap (splitRight out)))

growCore :: (Ord a) => LIST a (x,TREE a x) -> TREE a (Either x (LIST a x))
growCore NIL = EMPTY
growCore (CONS a (et, EMPTY)) = NODE (Left et) a (Left et)
growCore (CONS a (nt, NODE l b r))
  | a < b      =  NODE (Right (CONS a l)) b (Left r)
  | otherwise  =  NODE (Left l) b (Right (CONS a r))

-- Flattening a search tree.

flatten1, flatten2 :: (Ord elem) => Tree elem -> [elem]
flatten1  =  fold    (apo   (flattenCore . fmap (splitRight out)))
flatten2  =  unfold  (para  (fmap (joinRight inn) . flattenCore))

flattenCore :: (Ord a) => TREE a (x, LIST a x) -> LIST a (Either x (TREE a x))
flattenCore EMPTY = NIL
flattenCore (NODE (y, NIL) elem (x, _)) = CONS elem (Left x)
flattenCore (NODE (y, (CONS al l)) elem (x, _)) = CONS al (Right (NODE l elem x))

flatten1', flatten2' :: (Ord elem) => Tree elem -> [elem]
flatten1'  =  fold    (apo   (flattenCore' . fmap (splitRight out)))
flatten2'  =  unfold  (para  (fmap (joinRight inn) . flattenCore'))

flattenCore' :: (Ord a) => TREE a (x, LIST a x) -> LIST a (Either x (TREE a x))
flattenCore' EMPTY = NIL
flattenCore' (NODE (y, _) elem (x, NIL)) = CONS elem (Left y)
flattenCore' (NODE (y, _) elem (x, (CONS ar r))) = CONS ar (Right (NODE y elem r))


sort1, sort2, sort3, sort4, reverseSort1, reverseSort2, reverseSort3, reverseSort4 :: (Ord a) => [a] -> [a]
sort1 = flatten1 . grow1
sort2 = flatten1 . grow2
sort3 = flatten2 . grow1
sort4 = flatten2 . grow2
reverseSort1 = flatten1' . grow1
reverseSort2 = flatten1' . grow2
reverseSort3 = flatten2' . grow1
reverseSort4 = flatten2' . grow2
