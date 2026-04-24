module Adapter.Cli (runCli) where

import Bootstrap (Env (..))
import Control.Monad.Trans.Except (ExceptT, runExceptT)
import Domain.Model (AppError)
import Domain.Port (Logger (..))
import Domain.Usecase (deploy, list)
import Options.Applicative
import System.Exit (exitFailure)

data Command
  = Deploy String
  | Update String
  | Up String
  | Down String
  | List
  deriving (Show)

-- Command info for command variant. [arg name] -> [description]
cmdInfo :: (String -> Command) -> String -> String -> ParserInfo Command
cmdInfo c name desc = info (c <$> argument str (metavar name)) (progDesc desc)

-- Subcommand parser
commandParser :: Parser Command
commandParser =
  hsubparser
    ( command "deploy" (cmdInfo Deploy "URL" "Fetch and deploy a project")
        <> command "update" (cmdInfo Update "NAME" "Update a project")
        <> command "up" (cmdInfo Up "NAME" "Start a project container")
        <> command "down" (cmdInfo Down "NAME" "Stop a project container")
    )

-- Execute command parser on input
mainParser :: IO Command
mainParser = execParser (info commandParser (progDesc "Lunch"))

-- Run given domain function. Prints and exits on error.
runCommand :: Env -> ExceptT AppError IO () -> IO ()
runCommand env f = do
  result <- runExceptT f
  case result of
    Left err -> do
      logError (envLogger env) (show err)
      exitFailure
    Right _ -> pure ()

runCli :: Env -> IO ()
runCli env = do
  c <- mainParser
  case c of
    Deploy url -> do runCommand env (deploy env url)
    List -> do runCommand env (list env)
    Update _ -> pure ()
    Up _ -> pure ()
    Down _ -> pure ()