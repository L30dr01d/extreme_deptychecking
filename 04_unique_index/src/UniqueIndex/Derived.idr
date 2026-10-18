module UniqueIndex.Derived

import public UniqueIndex

import Deriving.DepTyCheck.Gen

%default total

%logging "deptycheck.derive" 20

UniqueIndex.genListOfPreds = deriveGen
