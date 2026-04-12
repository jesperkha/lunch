module Domain.Usecase (deploy, abort) where

import Data.List.Split (splitOn)
import Domain.Model (ProjectUrl)
import Domain.Port (DockerRepo (buildProject), Env (..), GitRepo (..), Logger (..))
import System.Directory.Internal.Prelude (exitFailure)
import System.FilePath (takeBaseName, (</>))

-- Destination root dir of downloaded projects
workDir :: FilePath
workDir = "./data"

-- Get only the repo name from the github url
projectName :: String -> String
projectName url = takeBaseName (last $ splitOn "/" url)

-- | Deploy a given github repo.
deploy :: Env IO -> ProjectUrl -> IO ()
deploy env url = do
  -- Clone github repo into local folder
  let outDir = workDir </> projectName url
  cloneRepo (envGitRepo env) url outDir
  buildProject (envDockerRepo env) outDir

-- | Abort execution by propagating IO error
abort :: Logger -> String -> IO ()
abort logger s = do
  logError logger s
  exitFailure
