module Domain.Port.Logger where

data Logger = Logger
  { logInfo :: String -> IO (),
    logError :: String -> IO (),
    logWarn :: String -> IO ()
  }