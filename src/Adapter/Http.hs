{-# LANGUAGE OverloadedStrings #-}

module Adapter.Http (runHttp) where

import Bootstrap (Env (..))
import Control.Monad.Trans.Except (runExceptT)
import Data.Text.Lazy (Text, pack, unpack)
import Domain.Usecase (deploy)
import Network.HTTP.Types.Status (status200, status500)
import Web.Scotty

runHttp :: Env -> IO ()
runHttp env = scotty 8080 $ do
  get "/" $ do
    text "OK"

  post "/deploy" $ do
    url <- queryParam "url" :: ActionM Text
    result <- liftIO $ runExceptT (deploy env (unpack url))
    case result of
      Left err -> do
        status status500
        text (pack $ show err)
      Right _ ->
        status status200
