# Huffman Trees

Enter your solutions into the file `src/Huffman.hs`. Use `cabal repl`
to work to test your work interactively in the REPL. Use `cabal run`
to run the automated tests.

## Encoding

After reading [the slides](./huffman-slides.pdf) about Huffman trees
you should have an understanding of the data structures and algorithms
involved. You will be modelling *frequency tables* as follows:

```haskell
type FreqTable a = [(a, Int)]
```

The module also contains a data type of binary trees, `HTree a`, where
each node carries an int (representing frequency counts), and
leaves carry an additional piece of data of type a (e.g. a char). A
`HTree` is a Huffman Tree. In a leaf node, (`Leaf i c`), `i` represents
the frequency of occurence of `c`. In a branch node (`Branch i l r`), `i`
represents the combined frquencies of the left and right children.

```haskell
data HTree a = Leaf Int a | Branch Int (HTree a) (HTree a) deriving (Show, Eq)
```

0. Make `HTree a` into an instance of the `Ord` typeclass. To do this
you need to provide a definition of `(<=)` for `HTree`. One `HTree`
is less than another if and only if its frequency label is less. That
is, leaves are not necessarily less than branches and vice versa.

1. Complete the `ftable` function which constructs the sorted
   frequency table for the input `[a]`. 
   
   ```haskell
   *Huffman> fTable "aabba c"
   [(' ',1),('c',1),('b',2),('a',3)]
   ```

   There are various ways to approach the problem. A nice way to do it
   is to begin by creating a
   [Map](https://hackage.haskell.org/package/containers-0.4.0.0/docs/Data-Map.html)
   from unique values in the data (the type of these values is `Char`
   in the example above but it could be any type in the `Ord`
   typeclass). Then, for every element in the input we want to do one
   of two things: if it is the first time we have seen it, insert it
   as a new key in the map with the value 1, or, if this is already a
   key in the map, increase the count by 1. We could do this with an
   `if` statement but there is a function in the Map library that does
   just what we need:
   [`insertWith`](https://hackage.haskell.org/package/containers-0.4.0.0/docs/Data-Map.html#v:insertWith).

   Having created the map, we can extract the `(key, value)` pairs
   (see the `toList` function) and sort them using the
   [`sortBy`](https://hackage.haskell.org/package/base-4.16.0.0/docs/Data-List.html#v:sortBy)
   function from `Data.List`.


2. Complete the `insert` function, which inserts a `HTree` node into a
   list sorted by ascending frequency.

   ```haskell
   *Main> let ts =  [Leaf 42 'a']
   *Huffman> let ts =  insert (Branch 19 (Leaf 1 'b') (Leaf 2 'c')) [Leaf 42 'a']
   *Huffman> ts
   [Branch 19 (Leaf 1 'b') (Leaf 2 'c'),Leaf 42 'a']
   *Huffman> insert (Leaf 25 'd') ts
   [Branch 19 (Leaf 1 'b') (Leaf 2 'c'),Leaf 25 'd',Leaf 42 'a']
   ```

3. Merge a list of `HTree` nodes into a single `Maybe HTree`. If the
   input is empty, return `Nothing`. If the input contains a single
   element, return a singleton list as a `Maybe`. Otherwise, do the
   following:
    * create a `Branch` node from the first two elements in the input,
	* use your `insert` function to insert this new
      element in the right place in the new list, which is formed of the old 
      list without its first two elements,
    * call `merge` recursively on the new list.

   When merging two nodes, `n1` and `n2`, the node with the lowest frequency
   should be the left-hand child in the new `Branch` node.

   ```haskell
   *Huffman> let ts = [Branch 19 (Leaf 1 'b') (Leaf 2 'c'),Leaf 25 'd',Leaf 42 'a']
   *Huffman> merge t2
   Just (Branch 86 (Leaf 42 'a') (Branch 44 (Branch 19 (Leaf 1 'b') (Leaf 2 'c')) (Leaf 25 'd')))
   ```
4. Complete the `tree` function, which constructs the Huffman tree for
   the input `[a]`. Return `Nothing` if the input is empty.
   Otherwise, do the following:
    * construct the frequency table for `str`,
	* use the frequency table to create a list of Leaf nodes, 
	* merge that list into a single tree by calling your `merge`
      function.
	  
   You can use the `printMaybeTree` function to display trees:
  
   ```haskell
*Huffman> printMaybeTree $ tree "aabba c"
            7             
            |             
   -------------          
  /             \         
3:'a'           4         
                |         
             ----------   
            /          \  
            2        2:'b'
            |             
          ------          
         /      \         
       1:'c'  1:' '  
   ```

5. Complete the `generateCode` function, which retrieves the code
   embodied by a Huffman tree, which is essentially a list of all the
   unique paths in the tree, where each path is associated with the
   value stored in the leaf. Each path is a list of `PathPart` values,
   i.e. `L` (left turn), `R` (right turn), or `E a` (the end of a
   path).
   
   The function returns a `HCode`, which is a lookup table of `Code`
   values, each of which is a `Path` from the root to one of the
   leaves of the tree, indexed by the value that is found at the leaf.
   
    ```haskell
    *Huffman> :m + Data.Maybe
    *Huffman Data.Maybe> generateCode $ fromJust $ tree "aabba c"
    [('a',[L]),('c',[R,L,L]),(' ',[R,L,R]),('b',[R,R])]
    ```

6. Complete the `encode` function, which does the following:

    * create the tree, `t`, for the input, `str`, 
	* generate the code for that tree,
	* use that code to encode the input, returning a pair of the
      entire `Path` for this input and the `HTree` associated with it
      (so that it can be decoded later).
	
	Encode the input, `str`, by looking up each element in `str` in the
	lookup table and adding its path to a list. 

    ```haskell
    *Huffman> encode "aabba c"
    Just ([L,L,R,R,R,R,L,R,L,R,R,L,L],Branch 7 (Leaf 3 'a') (Branch 4 (Branch 2 (Leaf 1 'c') (Leaf 1 ' ')) (Leaf 2 'b')))
    ```

7. Complete the `decode` function, which takes a tree and some encoded
   input, then returns the decoded result.

    ```haskell
    *Huffman Data.Maybe> let (t, path) = fromJust $ encode "aabba c"
    *Huffman Data.Maybe> decode t path
    "aabba c"
    ```
