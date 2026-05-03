{-# LANGUAGE OverloadedStrings #-}

module Infra.Docker (newDockerRepo) where

import Control.Monad (unless)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Trans.Except (throwE)
import Data.Aeson (Value, decode, withObject, (.:))
import Data.Aeson.Types (Parser, parseMaybe)
import qualified Data.ByteString.Lazy.Char8 as BSL
import Data.Maybe (listToMaybe)
import Domain.Model (AppError (..), AppInfo (AppInfo), AppStatus (..), ContainerInfo (..), Result)
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
  result <- tryCmd "docker" (["compose", "--project-directory", dir] <> args)
  case result of
    Left e -> do
      lift $ logError logger (show e)
      throwE err
    Right _ -> pure ()

-- | Parse json output from Docker inspect command into ContainerInfo.
parseInspectJson :: String -> Maybe ContainerInfo
parseInspectJson raw = do
  arr <- decode (BSL.pack raw) :: Maybe [Value]
  val <- listToMaybe arr
  parseMaybe parseContainer val

parseContainer :: Value -> Parser ContainerInfo
parseContainer = withObject "container" $ \o -> do
  name <- o .: "Name"
  state <- o .: "State"
  status <- state .: "Status"
  running <- state .: "Running"
  config <- o .: "Config"
  image <- config .: "Image"
  pure
    ContainerInfo
      { cName = name,
        cStatus = status,
        cRunning = running,
        cImage = image
      }

newDockerRepo :: Logger -> DockerRepo
newDockerRepo logger =
  DockerRepo
    { buildProject = runCompose logger "Building Docker image for " ["up", "--build", "-d"] (DockerError "Docker build failed"),
      composeDown = runCompose logger "Stopping " ["down"] (DockerError "Docker compose down failed"),
      getCid = \fp -> do
        result <- tryCmd "docker" ["compose", "--project-directory", fp, "ps", "-q"]
        case result of
          Left e -> do
            lift $ logError logger (show e)
            throwE (DockerError "Failed to read container id")
          Right cid -> pure $ if cid == "" then Nothing else Just cid,
      getInfo = \name cid -> do
        result <- tryCmd "docker" ["inspect", cid]
        maybeInfo <- case result of
          Left e -> do
            lift $ logError logger (show e)
            throwE (DockerError "Failed to inspect container")
          Right raw -> pure $ parseInspectJson raw
        case maybeInfo of
          Just cinfo -> pure (AppInfo name (if cRunning cinfo then Running else Stopped))
          Nothing -> throwE $ DockerError "Failed to parse inspect output"
    }
