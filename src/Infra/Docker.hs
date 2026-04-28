module Infra.Docker (newDockerRepo) where

import Control.Monad (unless)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..), Result)
import Domain.Port (DockerRepo (..), Logger (..))
import Pkg.IO (tryCmd)
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName, (</>))

checkDockerFiles :: FilePath -> Result ()
checkDockerFiles path = do
  fileMustExist (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist (path </> "docker-compose.yml") "Missing docker-compose.yml"

fileMustExist :: FilePath -> String -> Result ()
fileMustExist path msg = do
  exists <- lift $ doesFileExist path
  unless exists $ throwE (ConfigError msg)

runCompose :: Logger -> String -> AppError -> [String] -> FilePath -> Result ()
runCompose logger msg err args dir = do
  checkDockerFiles dir
  lift $ logInfo logger (msg <> takeBaseName dir <> "...")
  result <- tryCmd "docker" (["compose", "-f", dir </> "docker-compose.yml"] <> args)
  case result of
    Left e -> do
      lift (logError logger (show e))
      throwE err
    Right _ -> pure ()

newDockerRepo :: Logger -> DockerRepo
newDockerRepo logger =
  DockerRepo
    { buildProject = runCompose logger "Building Docker image for " (DockerError "Docker build failed") ["up", "--build", "-d"],
      composeUp = runCompose logger "Starting " (DockerError "Docker compose up failed") ["up", "-d"],
      composeDown = runCompose logger "Stopping " (DockerError "Docker compose down failed") ["down"]
    }
