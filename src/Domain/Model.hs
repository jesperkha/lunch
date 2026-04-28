module Domain.Model (ProjectUrl, ProjectName, AppError (..), Result) where

import Control.Monad.Trans.Except (ExceptT)

type ProjectUrl = String

type ProjectName = String

-- | Result t is a type alias for an ExceptT wrapping AppError and IO t.
type Result t = ExceptT AppError IO t

data AppError = GitError String | DockerError String | ConfigError String | IOError String | FsError String
  deriving (Show)