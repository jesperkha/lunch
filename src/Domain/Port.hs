module Domain.Port (Logger (..), GitRepo (..), Env (..)) where

import Domain.Model (ProjectUrl)

-- | Env is the collection of ports used by domain usecases and service
data Env m
  = Env
  { envLogger :: Logger,
    envGitRepo :: GitRepo m
  }

-- | Logger is a simple interface for printing out formatted strings
data Logger = Logger
  { logInfo :: String -> IO (),
    logError :: String -> IO (),
    logWarn :: String -> IO ()
  }

-- | GitRepo handles actions related to git
newtype GitRepo m = GitRepo
  { -- Clone a remote git repo into the given filepath
    cloneRepo :: ProjectUrl -> FilePath -> m ()
  }