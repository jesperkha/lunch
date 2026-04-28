module Domain.Usecase (deploy, list, up, remove) where

import Control.Monad.Trans.Class (MonadTrans (lift))
import Data.List.Split (splitOn)
import Domain.Model (ProjectName, ProjectUrl, Result)
import Domain.Port (DockerRepo (buildProject), Env (..), FsRepo (..), GitRepo (..))
import Pkg.IO (promptYesNo)
import System.FilePath (takeBaseName, (</>))

workDir :: FilePath
workDir = "./data"

projectName :: String -> String
projectName url = takeBaseName (last $ splitOn "/" url)

-- | Pull, build, and deploy a given GitHub repo
deploy :: Env -> ProjectUrl -> Result ()
deploy env url = do
  let outDir = workDir </> projectName url
  cloneRepo (envGitRepo env) url outDir
  buildProject (envDockerRepo env) outDir

-- | List downloaded projects
list :: Env -> Result ()
list env = do
  projects <- readDir (envFs env) workDir
  lift $ mapM_ putStrLn projects

-- | Start the docker container for the given project
up :: Env -> ProjectName -> Result ()
up env project = pure ()

-- | Delete a project directory
remove :: Env -> ProjectName -> Result ()
remove env project = do
  confirm <- lift $ promptYesNo ("Are you sure you want to remove " <> project <> "?")
  let projectPath = workDir </> project
  (if confirm then removeDir (envFs env) projectPath else lift $ putStrLn "Aborting")