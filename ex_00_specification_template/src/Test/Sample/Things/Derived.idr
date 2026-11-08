module Test.Sample.Things.Derived

import Deriving.DepTyCheck.Gen

import public Test.Sample.Things

%default total

%logging "deptycheck" 20

Test.Sample.Things.genSampleType = deriveGen
