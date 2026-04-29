module Main where

import Adapter.Cli (runCli)
import Adapter.Http (runHttp)
import Bootstrap (bootstrap)
import Data.Maybe (fromMaybe)
import System.Environment (lookupEnv)
import System.Exit (exitFailure)

main :: IO ()
main = do
  env <- bootstrap

  adapterEnv <- lookupEnv "ADAPTER"
  let adapter = fromMaybe "cli" adapterEnv

  case adapter of
    "cli" -> runCli env
    "http" -> runHttp env
    _ -> do
      putStrLn "Invalid ADAPTER environment value"
      exitFailure
