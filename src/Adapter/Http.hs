{-# LANGUAGE OverloadedStrings #-}

module Adapter.Http (runHttp) where

import Bootstrap (Env (..))
import Control.Monad.Trans.Except (runExceptT)
import Data.Text.Lazy (Text, pack, unpack)
import Domain.Model (Result)
import Domain.Port (Logger (..))
import Domain.Usecase (deploy)
import Network.HTTP.Types.Status (Status, status200, status500)
import Web.Scotty

-- Run domain action. Passing a tuple of status codes for (success, error).
runHandler :: Env -> (Status, Status) -> Result () -> ActionM ()
runHandler env s f = do
  result <- liftIO $ runExceptT f
  case result of
    Left err -> do
      liftIO $ logError (envLogger env) (show err)
      text (pack $ show err)
      status $ fst s
    Right _ ->
      status $ snd s

runHttp :: Env -> IO ()
runHttp env = scotty 8080 $ do
  get "/" $ do
    text "OK"

  post "/deploy" $ do
    url <- queryParam "url" :: ActionM Text
    runHandler env (status200, status500) (deploy env (unpack url))