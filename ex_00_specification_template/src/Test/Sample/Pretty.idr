module Test.Sample.Pretty

import Data.Fuel

import Test.DepTyCheck.Gen
import Text.PrettyPrint.Bernardy

import Test.Sample.Things

%default total

export
print : {opts : _} -> Fuel -> SampleType -> Gen0 $ Doc opts
print x A = pure $ line "A" 
print x B = pure $ line "A" 
