module Infra.Git where

import Domain.Port (GitRepo (..), Logger, logInfo)
import System.Process (callProcess)

workDir :: FilePath
workDir = "./data"

newGitRepo :: Logger -> GitRepo IO
newGitRepo logger =
  GitRepo
    { cloneRepo = \url path -> do
        logInfo logger $ "Cloning " <> url <> " into " <> path <> "..."
        callProcess "git" ["clone", "https://" <> url, path]
    }
