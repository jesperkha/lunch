module Infra.Docker (newDockerRepo) where

import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..), Result)
import Domain.Port (DockerRepo (..), Logger (..))
import Pkg.IO (tryCmd)
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName)
import System.FilePath.Posix ((</>))

checkDockerFiles :: FilePath -> Result ()
checkDockerFiles path = do
  fileMustExist (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist (path </> "docker-compose.yml") "Missing docker-compose.yml"

fileMustExist :: FilePath -> String -> Result ()
fileMustExist path msg = do
  exists <- lift $ doesFileExist path
  if exists
    then pure ()
    else do
      throwE (ConfigError msg)

newDockerRepo :: Logger -> DockerRepo
newDockerRepo logger =
  DockerRepo
    { buildProject = \dir -> do
        checkDockerFiles dir
        lift $ logInfo logger ("Building Docker image for " <> takeBaseName dir <> "...")
        result <- tryCmd "docker" ["compose", "-f", dir <> "/docker-compose.yml", "--build", "-d"]
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "docker build failed")
          Right _ -> pure ()
    }
