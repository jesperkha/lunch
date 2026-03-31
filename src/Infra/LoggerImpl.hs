module Infra.LoggerImpl where

import Domain.Port.Logger (Logger (..))

newLogger :: IO Logger
newLogger =
  pure
    Logger
      { logInfo = \msg -> putStrLn $ "[INFO] " <> msg,
        logWarn = \msg -> putStrLn $ "[WARN] " <> msg,
        logError = \msg -> putStrLn $ "[ERROR] " <> msg
      }