module Main where

import Adapter.Cli (runCli)
-- import Adapter.Http (runHttp)
import Bootstrap (bootstrap)

main :: IO ()
main = do
  env <- bootstrap
  runCli env
