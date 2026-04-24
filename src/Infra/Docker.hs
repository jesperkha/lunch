module Infra.Docker (newDockerRepo) where

import Control.Monad (unless)
import Domain.Port (DockerRepo (..), Logger (..))
import Domain.Usecase (abort)
import System.Directory (doesFileExist)
import System.FilePath (takeBaseName)
import System.FilePath.Posix ((</>))
import System.Process (callProcess)

checkDockerFiles :: Logger -> FilePath -> IO ()
checkDockerFiles logger path = do
  fileMustExist logger (path </> "Dockerfile") "Missing Dockerfile"
  fileMustExist logger (path </> "docker-compose.yml") "Missing docker-compose.yml"

fileMustExist :: Logger -> FilePath -> String -> IO ()
fileMustExist logger path err = do
  exists <- doesFileExist path
  unless
    exists
    ( do
        abort logger err
    )

newDockerRepo :: Logger -> DockerRepo IO
newDockerRepo logger =
  DockerRepo
    { buildProject = \dir -> do
        -- Check that project has Dockerfile and docker-compose.yml
        checkDockerFiles logger dir
        -- Build docker image
        logInfo logger ("Building Docker image for " <> takeBaseName dir <> "...")
        callProcess "docker" ["compose", "-f", dir <> "/docker-compose.yml", "--build", "-d"]
    }
