module Main where

import Adapter.Cli (runCli)
import Bootstrap (bootstrap)

main :: IO ()
main = do
  env <- bootstrap
  runCli env
