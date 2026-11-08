module Test.Sample.Things

import Data.Fuel

import Test.DepTyCheck.Gen

%default total

public export 
data SampleType = A | B 

export
genSampleType : Fuel -> Gen0 SampleType
