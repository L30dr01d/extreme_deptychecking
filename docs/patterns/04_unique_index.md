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

isCompatible : A -> B -> Bool
-->

# [`04_unique_index`](https://github.com/L3odr0id/extreme_deptychecking/tree/master/04_unique_index) — postpone unique values generation

There is a common case in specifications when we need a structure where each element should hold some unique value.
It means that we have to generate such a value and then generate a proof that all other elements of that structure hold some distinct value.
Such a proof is very expensive for big structures.

Instead, give each element just a unique `Nat` and later call another independent generator that produces a random value for each `Nat`.
This can be simplified even more by using an index of each element as a unique identifier,
which is especially comfortable for lists because each list item has its own ordinal number.

**Task:** generate predicates and give each a unique name.

So instead of modifying predicates to generate a name for each and then an expensive predicate checking their uniqueness, we just generate a list.
Then we generate as many names as that list's length, so each element has its own name.

```idris
namespace UniqueIndex
  data BoolPred : A -> BsList -> Type where
    BPR : (fb : Fin bs.length) -> (pred : So (isCompatible a (index bs fb))) -> BoolPred a bs

  data ListOfPreds : A -> BsList -> Type where
    MkRes : List (BoolPred a bslist) -> ListOfPreds a bslist
```

The printer takes that list, generates a vector of unique names of the same length, and prints the names.

<!-- idris
{- Full definition appears in `04_unique_index`.
-->
```idris
printListOfPreds : {opts : LayoutOpts} -> {a : A} -> {bs : BsList} -> Fuel ->
                   ListOfPreds a bs -> Gen0 $ Doc opts
printListOfPreds x (MkRes xs) = do
  (names ** _) <- genNUniqueNames [] x (length xs) [] Empty
  printAny $ toList names
```
<!-- idris
-}
-->
