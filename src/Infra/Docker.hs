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
        result <- tryCmd "docker" ["compose", "-f", dir <> "/docker-compose.yml", "up", "--build", "-d"]
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "Docker build failed")
          Right _ -> pure (),
      composeUp = \dir -> do
        checkDockerFiles dir
        lift $ logInfo logger ("Starting " <> takeBaseName dir <> "...")
        result <- tryCmd "docker" ["compose", "-f", dir <> "/docker-compose.yml", "up", "-d"]
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "Docker compose up failed")
          Right _ -> pure (),
      composeDown = \dir -> do
        checkDockerFiles dir
        lift $ logInfo logger ("Starting " <> takeBaseName dir <> "...")
        result <- tryCmd "docker" ["compose", "-f", dir <> "/docker-compose.yml", "down"]
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "Docker compose down failed")
          Right _ -> pure ()
    }
