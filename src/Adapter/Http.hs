{-# LANGUAGE OverloadedStrings #-}

module Adapter.Http (runHttp) where

import Bootstrap (Env (..))
import Control.Monad.Trans.Except (runExceptT)
import Data.Text.Lazy (Text, pack, unpack)
import Domain.Model (Result)
import Domain.Port (Logger (..))
import Domain.Usecase (deploy, down, fetch, list, up)
import Network.HTTP.Types.Status (Status, status200, status500)
import Web.Scotty

-- Run domain action. Passing a tuple of status codes for (success, error).
runHandler :: (Show t) => Env -> (Status, Status) -> Result t -> ActionM ()
runHandler env s f = do
  result <- liftIO $ runExceptT f
  case result of
    Left err -> do
      liftIO $ logError (envLogger env) (show err)
      text (pack $ show err)
      status $ snd s
    Right tt -> do
      text (pack $ show tt)
      status $ fst s

logRequest :: Logger -> String -> String -> ActionM ()
logRequest logger method url = liftIO $ logInfo logger (method <> " " <> url)

-- | Run the HTTP adapter
runHttp :: Env -> IO ()
runHttp env = scotty 8080 $ do
  let logger = envLogger env

  get "/" $ do
    text "OK"

  post "/deploy" $ do
    url <- queryParam "url" :: ActionM Text
    logRequest logger "POST" ("/deploy?url=" <> show url)
    runHandler env (status200, status500) (deploy env (unpack url))

  post "/fetch" $ do
    url <- queryParam "url" :: ActionM Text
    logRequest logger "POST" ("/fetch?url=" <> show url)
    runHandler env (status200, status500) (fetch env (unpack url))

  get "/list" $ do
    logRequest logger "GET" "/list"
    runHandler env (status200, status500) (list env)

  post "/up" $ do
    project <- queryParam "project" :: ActionM Text
    logRequest logger "POST" ("/up?project=" <> show project)
    runHandler env (status200, status500) (up env (unpack project))

  post "/down" $ do
    project <- queryParam "project" :: ActionM Text
    logRequest logger "POST" ("/down?project=" <> show project)
    runHandler env (status200, status500) (down env (unpack project))