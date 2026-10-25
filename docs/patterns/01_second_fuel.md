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

# [`01_second_fuel`](https://github.com/L3odr0id/extreme_deptychecking/tree/master/01_second_fuel) — a `Nat` used like extra fuel

Sometimes generators for even recursive structures are not total.
This happens when derivator can't prove that there is a decreasing index.
DepTyCheck automatically manages structural fuel for generators, but you can also introduce custom, type-level fuel to bypass standard fuel consumption.
For instance, a recursive structure can be indexed by a separate `Nat` that acts as a domain-specific fuel source allowing generation to follow that `Nat` index without exhausting the default DepTyCheck fuel budget.

**Task:** build a list whose length is tied to a `Fin` index (each step consumes one unit).

In the trivial implementation, length is determined solely by the `Fin`.
It uses `weaken` so that `Fin n` keeps its `n` across all iterations.
However, it **does not generate** values for `Fin` > `Fuel`, because it consumes fuel on each element.
Without `weaken`, such a structure would not consume fuel.

```idris
namespace ConsumersListFin
  data ConsumersListFin : Fin (S n) -> Type where
    Nil  : ConsumersListFin FZ
    (::) : FinConsumer f -> ConsumersListFin (weaken i) -> ConsumersListFin (FS i)
```

To work with `weaken`, the type can be indexed by a separate `Nat` length, which acts as alternative fuel.
It is crucial that this `Nat` equals the size of the `Fin`.

```idris
namespace ConsumersListFNat
  data ConsumersListFNat : Fin (S n) -> Nat -> Type where
    Nil  : ConsumersListFNat FZ Z
    (::) : FinConsumer f -> ConsumersListFNat (weaken i) k -> ConsumersListFNat (FS i) (S k)
```
