module Infra.Fs (newFsRepo) where

import Control.Monad.Trans.Class (MonadTrans (..))
import Domain.Model (throwFs)
import Domain.Port (FsRepo (..), Logger (logError, logInfo))
import Pkg.IO (tryIO)
import System.Directory (listDirectory, removeDirectoryRecursive)

newFsRepo :: Logger -> FsRepo
newFsRepo logger =
  FsRepo
    { readDir = lift . listDirectory,
      removeDir = \project -> do
        lift $ logInfo logger ("Deleting " <> project)
        result <- tryIO $ removeDirectoryRecursive project
        case result of
          Left err -> do
            lift $ logError logger (show err)
            throwFs ("Failed to delete directory: " <> project)
          Right _ -> pure ()
    }