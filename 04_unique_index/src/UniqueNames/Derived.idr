module UniqueNames.Derived

import public UniqueNames

import Deriving.DepTyCheck.Gen
import System.Random.Pure.StdGen

%default total

%logging "deptycheck.derive" 20

UniqueNames.rawNewName' = deriveGen
