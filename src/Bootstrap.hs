module Bootstrap (Env (..), bootstrap) where

import Domain.Port (GitRepo (..), Logger)
import Infra.Git (newGitRepo)
import Infra.Logger (newLogger)

data Env m
  = Env
  { envLogger :: Logger,
    envGitRepo :: GitRepo m
  }

bootstrap :: IO (Env IO)
bootstrap = do
  let logger = newLogger
  let gitRepo = newGitRepo logger
  pure
    Env
      { envLogger = logger,
        envGitRepo = gitRepo
      }