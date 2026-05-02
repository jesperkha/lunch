module Domain.Port (Logger (..), GitRepo (..), DockerRepo (..), Env (..), FsRepo (..)) where

import Domain.Model (AppInfo, ContainerInfo, ProjectUrl, Result)

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
data GitRepo = GitRepo
  { -- | Clone a @github url@ into local @filepath@.
    cloneRepo :: ProjectUrl -> FilePath -> Result (),
    -- | Pull the latest changes from a project
    pullRepo :: FilePath -> Result ()
  }

-- | DockerRepo handles actions related to building and running docker images and compose.
data DockerRepo = DockerRepo
  { -- | Run docker compose up in @path@ with build flag.
    buildProject :: FilePath -> Result (),
    -- | Run docker compose down in @path@.
    composeDown :: FilePath -> Result (),
    -- | Get container ID. None if container is not running.
    getCid :: FilePath -> Result (Maybe String),
    -- | Get container info for a given container id.
    getInfo :: String -> Result AppInfo
  }

-- | FsRepo handles file system related actions
data FsRepo = FsRepo
  { -- | Read contents of a @path@.
    readDir :: FilePath -> Result [FilePath],
    -- | Delete a @directory@ recursively.
    removeDir :: FilePath -> Result ()
  }