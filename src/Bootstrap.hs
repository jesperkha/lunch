module Bootstrap (Env (..), bootstrap) where

import Domain.Port (Env (..))
import Infra.Docker (newDockerRepo)
import Infra.Fs (newFsRepo)
import Infra.Git (newGitRepo)
import Infra.Logger (newLogger)

-- | Bootstrap all dependencies
bootstrap :: IO Env
bootstrap = do
  let logger = newLogger
  let gitRepo = newGitRepo logger
  let dockerRepo = newDockerRepo logger
  let fsRepo = newFsRepo logger
  pure
    Env
      { envLogger = logger,
        envGitRepo = gitRepo,
        envDockerRepo = dockerRepo,
        envFs = fsRepo
      }
