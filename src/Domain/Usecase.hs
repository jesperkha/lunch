module Domain.Usecase (deploy, fetch, list, up, down, remove, update, status) where

import Control.Monad.Trans.Class (MonadTrans (lift))
import Data.List.Split (splitOn)
import Domain.Model (AppInfo (AppInfo), AppStatus (Stopped), ProjectName, ProjectUrl, Result, throwIo)
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

-- | Pull project
fetch :: Env -> ProjectUrl -> Result ()
fetch env url = do
  let outDir = projectDir $ projectName url
  cloneRepo (envGitRepo env) url outDir

-- | Update to the latest version
update :: Env -> ProjectName -> Result ()
update env project = do
  checkProjectExists project
  let projectPath = projectDir project
  pullRepo (envGitRepo env) projectPath

-- | List downloaded projects
list :: Env -> Result [ProjectName]
list env = readDir (envFs env) workDir

-- | Start the docker container for the given project
up :: Env -> ProjectName -> Result ()
up env project = do
  checkProjectExists project
  buildProject (envDockerRepo env) (projectDir project)

-- | Stop the docker container for the given project
down :: Env -> ProjectName -> Result ()
down env project = do
  checkProjectExists project
  composeDown (envDockerRepo env) (projectDir project)

-- | Delete a project directory
remove :: Env -> ProjectName -> Result ()
remove env project = do
  checkProjectExists project
  confirm <- lift $ promptYesNo ("Are you sure you want to remove " <> project <> "?") False
  let projectPath = projectDir project
  (if confirm then removeDir (envFs env) projectPath else lift $ putStrLn "Aborting")

status :: Env -> ProjectName -> Result AppInfo
status env project = do
  let dockerRepo = envDockerRepo env
  checkProjectExists project
  let projectPath = projectDir project
  maybeCid <- getCid dockerRepo projectPath
  case maybeCid of
    Nothing -> pure $ AppInfo project Stopped
    Just cid -> getInfo dockerRepo project cid

checkProjectExists :: ProjectName -> Result ()
checkProjectExists name = do
  result <- tryIO $ doesDirectoryExist (projectDir name)
  case result of
    Right True -> pure ()
    _ -> throwIo ("Project does not exist: " <> name)