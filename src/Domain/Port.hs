module Domain.Port (Logger (..), GitRepo (..), DockerRepo (..), Env (..), FsRepo (..)) where

import Domain.Model (ProjectUrl, Result)

-- | Env is the collection of ports used by domain usecases and service
data Env
  = Env
  { envLogger :: Logger,
    envGitRepo :: GitRepo,
    envDockerRepo :: DockerRepo,
    envFs :: FsRepo
  }

-- | Logger is a simple interface for printing out formatted strings
data Logger = Logger
  { logInfo :: String -> IO (),
    logError :: String -> IO (),
    logWarn :: String -> IO ()
  }

-- | GitRepo handles actions related to git
newtype GitRepo = GitRepo
  { cloneRepo :: ProjectUrl -> FilePath -> Result ()
  }

-- | DockerRepo handles actions related to building and running docker images and compose
newtype DockerRepo = DockerRepo
  { buildProject :: FilePath -> Result ()
  }

-- TODO: rename FsRepo -> ProjectRepo

-- | FsRepo handles file system related actions
data FsRepo = FsRepo
  { readDir :: FilePath -> Result [FilePath],
    removeDir :: FilePath -> Result ()
  }