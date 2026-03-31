module Main where

import Domain.Port.Logger (Logger (logInfo))
import Infra.Logger (newLogger)

main :: IO ()
main = do
  logger <- newLogger
  logInfo logger "Hello"
