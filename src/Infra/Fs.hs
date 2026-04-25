module Infra.Fs (newFsRepo) where

import Control.Monad.Trans.Class (MonadTrans (..))
import Domain.Port (FsRepo (..))
import System.Directory (listDirectory)

newFsRepo :: FsRepo
newFsRepo =
  FsRepo
    { readDir = lift . listDirectory
    }