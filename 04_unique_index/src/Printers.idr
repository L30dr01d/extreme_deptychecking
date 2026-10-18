module Printers

import Data.Fuel
import Data.Vect
import Test.DepTyCheck.Gen
import Text.PrettyPrint.Bernardy

import Pretty
import UniqueIndex
import UniqueNames

%default total

export
printListOfPreds : {opts : LayoutOpts} -> {a : A} -> {bs : BsList} -> Fuel ->
                   ListOfPreds a bs -> Gen0 $ Doc opts
printListOfPreds x (MkRes xs) = do
  (names ** _) <- genNUniqueNames [] x (length xs) [] Empty
  printAny $ toList names
