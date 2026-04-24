{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-unused-do-bind #-}

module Adapter.Http (runHttp) where

import Bootstrap (Env (..))
import Control.Exception (SomeException, displayException, try)
import Data.Text.Lazy
import Domain.Port (Logger (..))
import Domain.Usecase (deploy)
import Network.HTTP.Types.Status (status200)
import Web.Scotty

catchLog :: Logger -> IO a -> IO (Either SomeException a)
catchLog logger action = do
  result <- try action
  case result of
    Left err -> do
      logError logger (displayException err)
      pure (Left err)
    Right x ->
      pure (Right x)

runHttp :: Env IO -> IO ()
runHttp env = scotty 8080 $ do
  get "/" $ do
    text "OK"

  post "/deploy" $ do
    url <- queryParam "url" :: ActionM Text
    liftIO $ do
      catchLog (envLogger env) $ deploy env (unpack url)
    status status200