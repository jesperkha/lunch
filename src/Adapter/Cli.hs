{-# LANGUAGE ScopedTypeVariables #-}

module Adapter.Cli (runCli) where

import Bootstrap (Env (..))
import Control.Exception (IOException, try)
import Control.Monad.Trans.Except (runExceptT)
import Domain.Model (AppError, ProjectName, ProjectUrl, Result)
import Domain.Port (Logger (..))
import Domain.Usecase (deploy, down, fetch, list, remove, up)
import Options.Applicative
import System.Exit (exitFailure)

data Command
  = Deploy ProjectUrl -- Fetch, build, and deploy project
  | Fetch ProjectUrl -- Fetch project
  | Up ProjectName -- Start project
  | Down ProjectName -- Stop project
  | Remove ProjectName -- Remove project
  | List -- List projects
  deriving (Show)

-- | Give @command variant@ an @argument name@ and @description@.
cmdInfo :: (String -> Command) -> String -> String -> ParserInfo Command
cmdInfo c name desc = info (c <$> argument str (metavar name)) (progDesc desc)

commandParser :: Parser Command
commandParser =
  hsubparser
    ( command "deploy" (cmdInfo Deploy "URL" "Fetch and deploy a project")
        <> command "fetch" (cmdInfo Fetch "URL" "Fetch project")
        <> command "up" (cmdInfo Up "NAME" "Start a project container")
        <> command "down" (cmdInfo Down "NAME" "Stop a project container")
        <> command "remove" (cmdInfo Remove "NAME" "Remove a project")
        <> command "list" (info (pure List) (progDesc "List all downloaded projects"))
    )

-- Execute command parser on input
mainParser :: IO Command
mainParser = execParser (info commandParser (progDesc "Lunch"))

-- | Run domain function returning type t.
-- On error log error and exit with failure.
-- On success return result value
runCommand :: forall t. (Show t) => Env -> Result t -> IO t
runCommand env f = do
  result <- try (runExceptT f) :: IO (Either IOException (Either AppError t))
  case result of
    -- IO error
    Left ioErr -> do
      logError (envLogger env) (show ioErr)
      exitFailure
    -- Application error
    Right (Left appErr) -> do
      logError (envLogger env) (show appErr)
      exitFailure
    -- No error
    Right (Right v) -> pure v

-- | Run the CLI adapter
runCli :: Env -> IO ()
runCli env = do
  c <- mainParser
  case c of
    Deploy url -> runCommand env (deploy env url)
    Fetch url -> runCommand env (fetch env url)
    List -> do
      projects <- runCommand env (list env)
      mapM_ putStrLn projects
    Remove name -> runCommand env (remove env name)
    Up name -> runCommand env (up env name)
    Down name -> runCommand env (down env name)