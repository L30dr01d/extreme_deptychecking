<!-- idris
import Data.Fin
import Data.So

import Deriving.DepTyCheck.Gen

%default total

data A : Type
data B : Type

namespace BsList
  public export
  data BsList : Type where
    Nil  : BsList
    (::) : B -> BsList -> BsList

  public export
  length : BsList -> Nat
  length []      = 0
  length (_::xs) = S (length xs)

  public export %inline
  (.length) : BsList -> Nat
  (.length) = length

  public export
  index : (bs : BsList) -> Fin bs.length -> B

namespace FinsList
  public export
  data FinsList : Nat -> Type where
    Nil  : FinsList n
    (::) : Fin n -> FinsList n -> FinsList n

  public export
  length : FinsList n -> Nat
  length []      = 0
  length (_::xs) = S (length xs)

  public export %inline
  (.length) : FinsList n -> Nat
  (.length) = length

  public export
  index : (fs : FinsList n) -> Fin fs.length -> Fin n

  public export
  (++) : FinsList n -> FinsList n -> FinsList n
  (++) = ?finsAppend

data FinConsumer : Fin n -> Type
-->

# [`02_helper_type`](https://github.com/L3odr0id/extreme_deptychecking/tree/master/02_helper_type) — use an additional utility type

There is a common task in developing specifications for DepTyCheck when you need to make a predicate on some large dependent type.
It's always better to break your structure into smaller components and create small predicates to validate them.
But sometimes you need a predicate over a large structure.

**Task:** for example, split a given `FinsList` into exactly four groups that form a partition of it.

The naive approach is to implement a data type holding four lists and a permutation proof for these groups.
A generator for `NaivePartition` will not produce any values.

```idris
record FourGroups (n : Nat) where
  constructor MkFour
  g0 : FinsList n
  g1 : FinsList n
  g2 : FinsList n
  g3 : FinsList n

flat4 : FourGroups n -> FinsList n
flat4 (MkFour a b c d) = a ++ b ++ c ++ d

data IsPermutation : FinsList n -> FinsList n -> Type where

data NaivePartition : {n : Nat} -> (src : FinsList n) -> Type where
  MkNaive : (buckets : FourGroups n) ->
            (0 ok : IsPermutation src (flat4 buckets)) ->
            NaivePartition src
```

<!-- idris
addToBucket : FourGroups n -> Fin 4 -> Fin n -> FourGroups n
-->

To solve the problem, replace a hard-to-generate invariant with a helper type that builds a correct value step by step.
The helper type does not represent the domain logic.
It just helps the generator build the values you need.

`FillInto4` walks the source once.
Each step puts one element into a `Fin 4` bucket.
It also uses the second-fuel pattern: a `Fin` index paired with an additional `Nat` (`steps`), which must be given as `src.length`.

```idris
data FillInto4 : {n : Nat} ->
                 (src : FinsList n) ->
                 (pre : FourGroups n) ->
                 (left : Fin (S src.length)) ->
                 (steps : Nat) ->
                 (mid : FourGroups n) ->
                 Type where
  FEnd : FillInto4 src pre FZ 0 pre
  FPut : {i : Fin src.length} ->
         {k : Nat} ->
         (recur : FillInto4 src pre (weaken i) k mid) ->
         (target : Fin 4) ->
         FillInto4 src pre (FS i) (S k) (addToBucket mid target (index src i))
```
