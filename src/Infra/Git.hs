module Infra.Git (newGitRepo) where

import Control.Exception (IOException, try)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..))
import Domain.Port (GitRepo (..), Logger (..))
import System.Directory (doesPathExist)
import System.Process (callProcess)

newGitRepo :: Logger -> GitRepo
newGitRepo logger =
  GitRepo
    { cloneRepo = \url path -> do
        exists <- lift $ doesPathExist path
        if exists
          then lift $ logInfo logger "Project exists. Skipping clone."
          else do
            lift $ logInfo logger $ "Cloning " <> url <> " into " <> path <> "..."
            result <- lift (try (callProcess "git" ["clone", "https://" <> url, path]) :: IO (Either IOException ()))
            case result of
              Left err -> do
                throwE (GitError $ "Git clone failed" <> show err)
              Right _ -> pure ()
    }
