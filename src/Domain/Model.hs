module Domain.Model (ProjectUrl, ProjectName, AppError (..)) where

type ProjectUrl = String

type ProjectName = String

data AppError = GitError String | DockerError String | ConfigError String
  deriving (Show)