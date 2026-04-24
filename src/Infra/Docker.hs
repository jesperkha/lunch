module Infra.Docker (newDockerRepo) where

import Control.Exception (IOException, try)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (ExceptT, throwE)
import Domain.Model (AppError (..))
import Domain.Port (DockerRepo (..), Logger (..))
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName)
import System.FilePath.Posix ((</>))
import System.Process (callProcess)

checkDockerFiles :: FilePath -> ExceptT AppError IO ()
checkDockerFiles path = do
  fileMustExist (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist (path </> "docker-compose.yml") "Missing docker-compose.yml"

fileMustExist :: FilePath -> String -> ExceptT AppError IO ()
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
        result <- lift (try (callProcess "docker" ["compose", "-f", dir <> "/docker-compose.yml", "--build", "-d"]) :: IO (Either IOException ()))
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "docker build failed")
          Right _ -> pure ()
    }
