# Lunch

## What is this?

Simple CLI tool for pulling and setting up and serving a Docker compose project.

## Structure

Lunch follows a simple [DDD architecture](https://en.wikipedia.org/wiki/Domain-driven_design).

```
/Adapter        Adapters for domain actions
    Cli.hs          The CLI adapter. Handles arugment parsing and dispatching to domain usecases.

/Domain         Domain logic and types
    Model.hs        All domain models and types.
    Port.hs         Domain ports (dependencies)
    Usecase.hs      Domain usecases. Deployment, updates, etc.

/Infra          Implementation of domain ports
    Git.hs          Impl of GitRepo
    Logger.hs       Impl of Logger

Main.hs         Program entry point. Call bootstrap and adapter
Bootstrap.hs    Bootstrap all dependencies
```

