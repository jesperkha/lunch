module Infra.Docker (newDockerRepo) where

import Control.Monad (unless)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..), Result)
import Domain.Port (DockerRepo (..), Logger (..))
import Pkg.IO (tryCmd)
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName, (</>))

-- | Assert that both Dockerfile and docker-compose.yml exist in @path@.
checkDockerFiles :: FilePath -> Result ()
checkDockerFiles path = do
  fileMustExist (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist (path </> "docker-compose.yml") "Missing docker-compose.yml"

-- | Asserts that @file@ exists, returning @error message@ if not.
fileMustExist :: FilePath -> String -> Result ()
fileMustExist path msg = do
  exists <- lift $ doesFileExist path
  unless exists $ throwE (ConfigError msg)

-- | Run compose using @logger@ to print @info@.
-- Runs command with @args@ and returns @error@ on failure.
runCompose :: Logger -> String -> [String] -> AppError -> FilePath -> Result ()
runCompose logger msg args err dir = do
  checkDockerFiles dir
  lift $ logInfo logger (msg <> takeBaseName dir <> "...")
  result <- tryCmd "docker" (["compose", "-f", dir </> "docker-compose.yml"] <> args)
  case result of
    Left e -> do
      lift $ logError logger (show e)
      throwE err
    Right _ -> pure ()

newDockerRepo :: Logger -> DockerRepo
newDockerRepo logger =
  DockerRepo
    { buildProject = runCompose logger "Building Docker image for " ["up", "--build", "-d"] (DockerError "Docker build failed"),
      composeDown = runCompose logger "Stopping " ["down"] (DockerError "Docker compose down failed")
    }
