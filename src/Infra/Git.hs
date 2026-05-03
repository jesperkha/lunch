module Infra.Git (newGitRepo) where

import Control.Monad.Trans.Class (lift)
import Domain.Model (throwGit)
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
                throwGit ("Git clone failed" <> show err)
              Right _ -> pure (),
      pullRepo = \path -> do
        lift $ logInfo logger ("Pulling latest in " <> path <> "...")
        result <- tryCmd "git" ["-C", path, "pull"]
        case result of
          Left err -> do
            throwGit ("Git pull failed" <> show err)
          Right _ -> pure ()
    }
