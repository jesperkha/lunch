module Infra.Git where

import Domain.Port (GitRepo (..), Logger, logInfo)
import System.Process (callProcess)

workDir :: FilePath
workDir = "./data"

newGitRepo :: Logger -> GitRepo IO
newGitRepo logger =
  GitRepo
    { cloneRepo = \url path -> do
        logInfo logger $ "Cloning " <> url
        callProcess "git" ["clone", "https://" <> url, path]
        -- fetchLatest = \path -> do
        --   logInfo logger "Fetching latest changes"
        --   callProcess "git" ["-C", path, "pull", "--rebase"],
        -- repoExists = \(ProjectName name) -> do
        --   let path = workDir </> unpack name
        --   doesDirectoryExist (path </> ".git")
    }
