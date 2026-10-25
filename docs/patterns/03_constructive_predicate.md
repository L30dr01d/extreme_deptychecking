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

data IsCompatible : A -> B -> Type

goodFins : A -> (bs : BsList) -> FinsList bs.length
-->

# [`03_constructive_predicate`](https://github.com/L3odr0id/extreme_deptychecking/tree/master/03_constructive_predicate) — place predicate before `Fin` using only dependent types

Constructive predicates are valuable when the desirable arguments order is unknown, so depthcheck determine it.
While the resulting order may not be optimal, the selection process is entirely automated, which is very comfortable for the developer.

Here we compare ways to declare a predicate and a `Fin`.

**Task:** for each given `A`, pick a compatible element of the given `Bs`.

The naive approach is to generate a `Fin` first and then check compatibility using a predicate written in dependent types.

```idris
data DepTyPredResult : A -> BsList -> Type where
  DTPR : (fb : Fin bs.length) -> (pred : IsCompatible a (index bs fb)) -> DepTyPredResult a bs
```

The best performing approach is to select the `Fin`s of compatible `B`s using functions and then generate a `Fin` into them.
But this approach does not use dependent types.

```idris
data FuncPredResult : A -> BsList -> Type where
  MkFuncPred : (fb' : Fin (goodFins a bs).length) -> FuncPredResult a bs
```

The idea of filtering the list before `Fin` generation can be written using only dependent types.
The type `FilteredCompatibleFins` takes a given `A` and the initial `Bs` and returns a generated `FinsList` of `B`s compatible with that `A`.
Then a `Fin` can be generated into the filtered list.

This approach derives and generates values much more slowly than `FuncPredResult`, but it is implemented using dependent types almost entirely.

```idris
||| Proof that `A` and `B` are not compatible with each other
data NotCompatible : A -> B -> Type

namespace FinsList
  public export
  weakenFins : FinsList n -> FinsList (S n)
  weakenFins []      = []
  weakenFins (f::fs) = FS f :: weakenFins fs

data FilteredCompatibleFins : A -> (bs : BsList) -> FinsList bs.length -> Type where
  Nil  : FilteredCompatibleFins a [] []
  Keep : IsCompatible a b ->
         FilteredCompatibleFins a bs rest ->
         FilteredCompatibleFins a (b :: bs) (FZ :: weakenFins rest)
  Drop : NotCompatible a b ->
         FilteredCompatibleFins a bs rest ->
         FilteredCompatibleFins a (b :: bs) (weakenFins rest)

data FilteredFinsResult : A -> BsList -> Type where
  MkFilteredFins : (a : A) ->
                   {0 goodBFins : FinsList bs.length} ->
                   (0 filtered : FilteredCompatibleFins a bs goodBFins) ->
                   (finalFinB : Fin goodBFins.length) ->
                   FilteredFinsResult a bs
```

There is also one interesting idea. If `IsCompatible a b` is very heavy, that argument can be generated first to obtain a generated index `b`.
This `b` can then be used as an image to compare with other `B`s when filtering those compatible with a given `A`.
Such image doesn't have to be the exact type of `B`, it can be a simplified holder of some most important properties of `B`.
Although this doesn't make much sense in the presented trivial example, such an idea may be useful in more complex structures.

```idris
data FinB2 : Nat -> Type where
  MkFinB2 : Fin n -> B -> FinB2 n

data FinB2List : Nat -> Type

data FilteredBFinss : B -> (bs : FinB2List fullBs) -> FinsList fullBs -> Type

data ImageDepTyPredResult : A -> FinB2List fullBs -> Type where
  IDTPR : {0 b : B} -> {0 goodBFins : FinsList fullBs} ->
          (0 pred : IsCompatible a b) ->
          (0 filteredAsHelper : FilteredBFinss b finbs goodBFins) ->
          (finalFinB : Fin goodBFins.length) ->
          ImageDepTyPredResult a finbs

GenOrderTuning "IDTPR".dataCon where
  isConstructor = itIsConstructor
  deriveFirst _ _ = [`{pred}, `{b}, `{filteredAsHelper}, `{goodBFins}, `{finalFinB}]
```
