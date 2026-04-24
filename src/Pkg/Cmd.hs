module Pkg.Cmd (liftCmd) where

import Control.Exception (IOException)
import Control.Exception.Base (try)
import Control.Monad.Trans.Class (MonadTrans (lift))
import System.Process (callProcess)

liftCmd :: (MonadTrans a) => String -> [String] -> a IO (Either IOException ())
liftCmd name args = lift $ try (callProcess name args)