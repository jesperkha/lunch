module Domain.Usecase (deploy, list, up) where

import Control.Monad.Trans.Class (MonadTrans (lift))
import Control.Monad.Trans.Except (ExceptT)
import Data.List.Split (splitOn)
import Domain.Model (AppError, ProjectName, ProjectUrl)
import Domain.Port (DockerRepo (buildProject), Env (..), FsRepo (..), GitRepo (..))
import System.FilePath (takeBaseName, (</>))

workDir :: FilePath
workDir = "./data"

projectName :: String -> String
projectName url = takeBaseName (last $ splitOn "/" url)

-- | Pull, build, and deploy a given GitHub repo
deploy :: Env -> ProjectUrl -> ExceptT AppError IO ()
deploy env url = do
  let outDir = workDir </> projectName url
  cloneRepo (envGitRepo env) url outDir
  buildProject (envDockerRepo env) outDir

-- | List downloaded projects
list :: Env -> ExceptT AppError IO ()
list env = do
  projects <- readDir (envFs env) workDir
  lift $ mapM_ putStrLn projects

-- | Start the docker container for the given project
up :: Env -> ProjectName -> ExceptT AppError IO ()
up env project = pure ()