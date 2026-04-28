module Infra.Fs (newFsRepo) where

import Control.Monad.Trans.Class (MonadTrans (..))
import Control.Monad.Trans.Except (throwE)
import Domain.Model (AppError (..))
import Domain.Port (FsRepo (..), Logger (logError, logInfo))
import Pkg.IO (tryIO)
import System.Directory (listDirectory, removeDirectoryRecursive)

newFsRepo :: Logger -> FsRepo
newFsRepo logger =
  FsRepo
    { readDir = lift . listDirectory,
      removeDir = \project -> do
        lift $ logInfo logger $ "Deleting " <> project
        result <- tryIO $ removeDirectoryRecursive project
        case result of
          Left err -> do
            lift $ logError logger $ show err
            throwE $ FsError $ "Failed to delete directory: " <> project
          Right _ -> pure ()
    }