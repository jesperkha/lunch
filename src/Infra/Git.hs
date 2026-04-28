module Infra.Git (newGitRepo) where

import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..))
import Domain.Port (GitRepo (..), Logger (..))
import Pkg.IO (tryCmd)
import System.Directory (doesPathExist)

newGitRepo :: Logger -> GitRepo
newGitRepo logger =
  GitRepo
    { cloneRepo = \url path -> do
        exists <- lift $ doesPathExist path
        if exists
          then lift $ logInfo logger "Project exists. Skipping clone."
          else do
            lift $ logInfo logger ("Cloning " <> url <> " into " <> path <> "...")
            result <- tryCmd "git" ["clone", "https://" <> url, path]
            case result of
              Left err -> do
                throwE $ GitError ("Git clone failed" <> show err)
              Right _ -> pure ()
    }
