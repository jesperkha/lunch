module Domain.Usecase (deploy) where

import Control.Monad.Trans.Except (ExceptT)
import Data.List.Split (splitOn)
import Domain.Model (AppError, ProjectUrl)
import Domain.Port (DockerRepo (buildProject), Env (..), GitRepo (..))
import System.FilePath (takeBaseName, (</>))

workDir :: FilePath
workDir = "./data"

projectName :: String -> String
projectName url = takeBaseName (last $ splitOn "/" url)

-- | Deploy a given github repo.
deploy :: Env -> ProjectUrl -> ExceptT AppError IO ()
deploy env url = do
  let outDir = workDir </> projectName url
  cloneRepo (envGitRepo env) url outDir
  buildProject (envDockerRepo env) outDir
