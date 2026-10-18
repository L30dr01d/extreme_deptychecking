module Main

import Data.Fuel

import Test.DepTyCheck.Gen
import Text.PrettyPrint.Bernardy

import Cli
import Common
import UniqueIndex.Derived
import UniqueNames.Derived
import Printers

%default total

data Mode = UniqueIndexMode

parseMode : String -> Either String Mode
parseMode "uniqueindex" = Right UniqueIndexMode
parseMode mode          = Left $ "unknown generator `" ++ mode ++ "`. Expected uniqueindex"

defaultConfig : Cfg Mode
defaultConfig = MkConfig 10 (limit 4) UniqueIndexMode 10

covering
runSelected : Cfg Mode -> IO ()
runSelected cfg =
  case cfg.selected of
    UniqueIndexMode => run cfg.testsCnt (printListOfPreds cfg.modelFuel) $ genListOfPreds cfg.modelFuel MkA1 predefinedBs

covering
main : IO ()
main = mainWith
  "Usage: unique_index [OPTIONS]"
  parseMode
  " <uniqueindex>"
  defaultConfig
  runSelected
