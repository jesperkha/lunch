module Domain.Model (ProjectUrl, AppError (..)) where

type ProjectUrl = String

data AppError = GitError String | DockerError String | ConfigError String
  deriving (Show)