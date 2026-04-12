module Bootstrap (Env (..), bootstrap) where

import Domain.Port (Env (..))
import Infra.Git (newGitRepo)
import Infra.Logger (newLogger)

bootstrap :: IO (Env IO)
bootstrap = do
  let logger = newLogger
  let gitRepo = newGitRepo logger

  pure
    Env
      { envLogger = logger,
        envGitRepo = gitRepo
      }