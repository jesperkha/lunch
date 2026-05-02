{-# LANGUAGE ScopedTypeVariables #-}

module Pkg.IO (promptYesNo, tryIO, tryCmd) where

import Control.Exception (IOException)
import Control.Exception.Base (try)
import Control.Monad.Trans.Class (MonadTrans (..))
import Domain.Model (AppError (IOError), Result)
import System.IO (hFlush, stdout)
import System.Process (readProcess)

-- | Print a @message@ to the terminal and await user input.
-- Accepts a @default@ selected option (yes/no).
promptYesNo :: String -> Bool -> IO Bool
promptYesNo msg defaultSelect = do
  putStr $ msg <> (if defaultSelect then " (Y/n): " else " (y/N): ")
  hFlush stdout
  response <- getLine
  pure
    ( if defaultSelect
        then response `notElem` ["n", "N"]
        else response `elem` ["y", "Y"]
    )

-- | Try IO action and convert IO exception message to domain IOError.
tryIO :: forall t. IO t -> Result (Either AppError t)
tryIO f = lift $ do
  result <- try f :: IO (Either IOException t)
  case result of
    Left err -> pure $ Left $ IOError (show err)
    Right tt -> pure $ Right tt

-- | Try to run shell command and convert IO exception to domain IOError.
-- Returns process output
tryCmd :: String -> [String] -> Result (Either AppError String)
tryCmd name args = tryIO (readProcess name args "")
