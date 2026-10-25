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

# [`00_safe_select`](https://github.com/L3odr0id/extreme_deptychecking/tree/master/00_safe_select) — shrink the choice set before picking

**Task:** There are lists of `A` and `B`. For each `A`, pick an index into `Bs` that is compatible with `A`.
This is a very common task when writing specifications for DepTyCheck.

All examples follow the same pattern: a list of `A`s is given as an index, and for each value of `A` a `Fin` into `Bs` is generated.

The most trivial way to solve the task is to declare a function `isCompatible` and use it with `So` to create a filter predicate.

```idris
isCompatible : A -> B -> Bool

data BoolPredResult : A -> BsList -> Type where
  BPR : (fb : Fin bs.length) -> (pred : So (isCompatible a (index bs fb))) -> BoolPredResult a bs
```

It is preferable to work with dependent types rather than functions.
So it is better to declare a predicate `IsCompatible` and use it to filter incompatible options.

```idris
data IsCompatible : A -> B -> Type

data SimpleDepTyPredResult : A -> BsList -> Type where
  SDTPR : (fb : Fin bs.length) -> IsCompatible a (index bs fb) -> SimpleDepTyPredResult a bs
```

**Idea:** To get much better generation performance, instead of picking into the full list and proving compatibility afterward, narrow the search space to only valid candidates before choosing a `Fin`.

The naive approach to make generation faster is to declare a function that keeps only values compatible with a given `A`, then choose a `Fin` into that list.
The downside of this approach is that we get the compatible value of `B`, but not its index in the original list.

```idris
findCompatible : A -> (allBs : BsList) -> BsList

data CompValuesResult : A -> BsList -> Type where
  MkCompValues : (fb' : Fin (findCompatible a bs).length) -> CompValuesResult a bs
```

To preserve the original fins, a `goodFins` function can be declared. It should return the fins of `B`s that are compatible with a given `A`.
Then another `Fin` into that `FinsList` can be generated to choose any fin of a compatible `B`. This solution gives the best derivation and generation performance.

```idris
goodFins : A -> (bs : BsList) -> FinsList bs.length

data FuncPredResult : A -> BsList -> Type where
  MkFuncPred : (fb' : Fin (goodFins a bs).length) -> FuncPredResult a bs
```

It is also possible to solve this task using only dependent types.
`FilteredCompatibleFins` can be declared to take a given `A` and `Bs` list, and expose as a generated index the list of fins into `Bs` that are compatible with that `A`.

<!-- idris
{- Full definition appears in `03_constructive_predicate`.
-->
```idris
data FilteredCompatibleFins : A -> (bs : BsList) -> FinsList bs.length -> Type

data DepTyPredResult : A -> BsList -> Type where
  MkDepTyPred : {0 goodBFins : FinsList bs.length} ->
                (0 filtered : FilteredCompatibleFins a bs goodBFins) ->
                (finalFinB : Fin goodBFins.length) ->
                DepTyPredResult a bs
```
<!-- idris
-}
-->
