module Domain.Usecase (deploy, list, up, down, remove) where

import Control.Monad.Trans.Class (MonadTrans (lift))
import Control.Monad.Trans.Except (throwE)
import Data.List.Split (splitOn)
import Domain.Model (AppError (IOError), ProjectName, ProjectUrl, Result)
import Domain.Port (DockerRepo (..), Env (..), FsRepo (..), GitRepo (..))
import Pkg.IO (promptYesNo, tryIO)
import System.Directory (doesDirectoryExist)
import System.FilePath (takeBaseName, (</>))

workDir :: FilePath
workDir = "./data"

projectDir :: ProjectName -> FilePath
projectDir p = workDir </> p

projectName :: String -> String
projectName url = takeBaseName (last $ splitOn "/" url)

-- | Pull, build, and deploy a given GitHub repo
deploy :: Env -> ProjectUrl -> Result ()
deploy env url = do
  let outDir = projectDir $ projectName url
  cloneRepo (envGitRepo env) url outDir
  buildProject (envDockerRepo env) outDir

-- | List downloaded projects
list :: Env -> Result [ProjectName]
list env = readDir (envFs env) workDir

-- | Start the docker container for the given project
up :: Env -> ProjectName -> Result ()
up env project = do
  checkProjectExists project
  composeUp (envDockerRepo env) (projectDir project)

-- | Stop the docker container for the given project
down :: Env -> ProjectName -> Result ()
down env project = do
  checkProjectExists project
  composeDown (envDockerRepo env) (projectDir project)

-- | Delete a project directory
remove :: Env -> ProjectName -> Result ()
remove env project = do
  checkProjectExists project
  confirm <- lift $ promptYesNo ("Are you sure you want to remove " <> project <> "?")
  let projectPath = projectDir project
  (if confirm then removeDir (envFs env) projectPath else lift $ putStrLn "Aborting")

checkProjectExists :: ProjectName -> Result ()
checkProjectExists name = do
  result <- tryIO $ doesDirectoryExist (projectDir name)
  case result of
    Right True -> pure ()
    _ -> throwE $ IOError ("Project does not exist: " <> name)