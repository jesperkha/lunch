module Bootstrap (Env (..), bootstrap) where

import Domain.Port.Logger (Logger)
import Infra.Logger (newLogger)

newtype Env = Env
  { envLogger :: Logger
  }

bootstrap :: IO Env
bootstrap = do
  logger <- newLogger
  pure
    Env
      { envLogger = logger
      }