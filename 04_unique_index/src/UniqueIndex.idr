module UniqueIndex

import Data.Fin
import Data.List
import Data.Vect

import Data.Fuel
import Test.DepTyCheck.Gen

import public Common

%default total

{-
  UniqueIndex pattern

  Task: generate a list where each item has unique name.
-}

public export
data BoolPred : A -> BsList -> Type where
  BPR : (fb : Fin bs.length) -> (pred : So (isCompatible a (index bs fb))) -> BoolPred a bs

public export
data ListOfPreds : A -> BsList -> Type where
  MkRes : List (BoolPred a bslist) -> ListOfPreds a bslist


export
genListOfPreds : Fuel -> (a : A) -> (bs : BsList) -> Gen MaybeEmpty $ ListOfPreds a bs

