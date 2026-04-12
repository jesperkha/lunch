module Domain.Port (Logger (..), GitRepo (..)) where

import Domain.Model (ProjectUrl)

data Logger = Logger
  { logInfo :: String -> IO (),
    logError :: String -> IO (),
    logWarn :: String -> IO ()
  }

newtype GitRepo m = GitRepo
  -- Clone a remote git repo into the given filepath
  { cloneRepo :: ProjectUrl -> FilePath -> m ()
  }