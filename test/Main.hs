module Main where

import Control.Monad (unless)
import Domain.Model (ContainerInfo (..))
import Domain.Usecase (projectName)
import Infra.Docker (parseInspectJson)
import System.Exit (exitFailure)

check :: String -> Bool -> IO ()
check name cond = unless cond $ putStrLn ("FAIL: " <> name) >> exitFailure

validJson :: String
validJson = "[{\"Name\":\"/myapp\",\"State\":{\"Status\":\"running\",\"Running\":true},\"Config\":{\"Image\":\"myimage:latest\"}}]"

stoppedJson :: String
stoppedJson = "[{\"Name\":\"/myapp\",\"State\":{\"Status\":\"exited\",\"Running\":false},\"Config\":{\"Image\":\"myimage:latest\"}}]"

main :: IO ()
main = do
  -- projectName
  check "projectName: extracts repo name" $
    projectName "github.com/user/repo" == "repo"
  check "projectName: handles hyphenated name" $
    projectName "github.com/user/my-app" == "my-app"

  -- parseInspectJson
  check "parseInspectJson: parses running container" $
    parseInspectJson validJson
      == Just ContainerInfo {cName = "/myapp", cStatus = "running", cRunning = True, cImage = "myimage:latest"}

  check "parseInspectJson: parses stopped container" $
    parseInspectJson stoppedJson
      == Just ContainerInfo {cName = "/myapp", cStatus = "exited", cRunning = False, cImage = "myimage:latest"}

  check "parseInspectJson: returns Nothing for empty array" $
    parseInspectJson "[]" == Nothing

  check "parseInspectJson: returns Nothing for invalid json" $
    parseInspectJson "not json" == Nothing

  putStrLn "All tests passed."
