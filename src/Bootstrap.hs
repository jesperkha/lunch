module Bootstrap (Env (..), bootstrap) where

import Domain.Port (Env (..))
import Infra.Docker (newDockerRepo)
import Infra.Git (newGitRepo)
import Infra.Logger (newLogger)

bootstrap :: IO Env
bootstrap = do
  let logger = newLogger
  let gitRepo = newGitRepo logger
  let dockerRepo = newDockerRepo logger
  pure
    Env
      { envLogger = logger,
        envGitRepo = gitRepo,
        envDockerRepo = dockerRepo
      }
