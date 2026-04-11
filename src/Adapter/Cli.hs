module Adapter.Cli where

import Bootstrap
import Options.Applicative

data Command
  = Deploy String
  | Update String
  | Up String
  | Down String
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

runCli :: Env -> IO ()
runCli _ = do
  c <- mainParser
  print c