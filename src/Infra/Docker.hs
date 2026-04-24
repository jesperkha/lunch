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

checkDockerFiles :: Logger -> FilePath -> ExceptT AppError IO ()
checkDockerFiles logger path = do
  fileMustExist logger (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist logger (path </> "docker-compose.yml") "Missing docker-compose.yml"

fileMustExist :: Logger -> FilePath -> String -> ExceptT AppError IO ()
fileMustExist logger path msg = do
  exists <- lift $ doesFileExist path
  if exists
    then pure ()
    else do
      lift $ logError logger msg
      throwE (ConfigError msg)

newDockerRepo :: Logger -> DockerRepo
newDockerRepo logger =
  DockerRepo
    { buildProject = \dir -> do
        checkDockerFiles logger dir
        lift $ logInfo logger ("Building Docker image for " <> takeBaseName dir <> "...")
        result <- lift (try (callProcess "docker" ["compose", "-f", dir <> "/docker-compose.yml", "--build", "-d"]) :: IO (Either IOException ()))
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwE (DockerError "docker build failed")
          Right _ -> pure ()
    }
