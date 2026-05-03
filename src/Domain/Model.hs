module Domain.Model (ProjectUrl, ProjectName, AppError (..), AppStatus (..), Result, AppInfo (..), ContainerInfo (..), throwGit, throwDocker, throwConfig, throwFs, throwIo) where

import Control.Monad.Trans.Except (ExceptT, throwE)

-- | A project url in the form "github.com\/user\/repo".
type ProjectUrl = String

-- | A project name. Usually the base name of a ProjectUrl.
type ProjectName = String

-- | Result t is a type alias for an ExceptT wrapping AppError and IO t.
type Result t = ExceptT AppError IO t

-- | AppError represents an error raised by lunch.
-- When alien functions return errors, they are logged, and an AppError replaces it.
-- IOError specifically is used to extract IOException messages.
data AppError = GitError String | DockerError String | ConfigError String | IOError String | FsError String
  deriving (Show)

-- | AppStatus contains current status information for a container.
data AppInfo = AppInfo
  { infoService :: String,
    infoStatus :: AppStatus
  }
  deriving (Show)

data AppStatus = Running | Stopped
  deriving (Show)

data ContainerInfo = ContainerInfo
  { cName    :: String,
    cStatus  :: String,
    cRunning :: Bool,
    cImage   :: String
  }

throwGit, throwDocker, throwConfig, throwFs, throwIo :: String -> Result a
throwGit    = throwE . GitError
throwDocker = throwE . DockerError
throwConfig = throwE . ConfigError
throwFs     = throwE . FsError
throwIo     = throwE . IOError