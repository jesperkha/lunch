module Domain.Port (Logger (..), GitRepo (..), DockerRepo (..), Env (..)) where

import Control.Monad.Trans.Except (ExceptT)
import Domain.Model (AppError, ProjectUrl)

-- | Env is the collection of ports used by domain usecases and service
data Env
  = Env
  { envLogger :: Logger,
    envGitRepo :: GitRepo,
    envDockerRepo :: DockerRepo
  }

-- | Logger is a simple interface for printing out formatted strings
data Logger = Logger
  { logInfo :: String -> IO (),
    logError :: String -> IO (),
    logWarn :: String -> IO ()
  }

-- | GitRepo handles actions related to git
newtype GitRepo = GitRepo
  { cloneRepo :: ProjectUrl -> FilePath -> ExceptT AppError IO ()
  }

-- | DockerRepo handles actions related to building and running docker images and compose
newtype DockerRepo = DockerRepo
  { buildProject :: FilePath -> ExceptT AppError IO ()
  }
