module Infra.Git (newGitRepo) where

import Domain.Port (GitRepo (..), Logger, logInfo)
import System.Directory (doesPathExist)
import System.Process (callProcess)

newGitRepo :: Logger -> GitRepo IO
newGitRepo logger =
  GitRepo
    { cloneRepo = \url path -> do
        -- Check if repo already exists
        exists <- doesPathExist path
        ( if exists
            then logInfo logger "Project exists. Skipping clone."
            else
              ( do
                  logInfo logger $ "Cloning " <> url <> " into " <> path <> "..."
                  callProcess "git" ["clone", "https://" <> url, path]
              )
          )
    }
