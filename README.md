# Lunch

## What is this?

Simple CLI tool for pulling and setting up and serving a Docker compose project.

## Build

Requirements:

- Docker (compose)
- Git

```sh
cabal build
```

You may need to install an additional `zlib` dev-dependency if it is missing. Look up how to install it with you systems package manager.

### Or with Docker Compose

Build and run the http adapter:

```sh
docker compose up --build -d
```

## Test

```sh
cabal test
```

## Use

Assuming you have built the binary as `lunch`.

### Cli

```sh
Usage: lunch COMMAND

  Lunch

Available options:
  -h,--help                Show this help text

Available commands:
  deploy                   Fetch and deploy a project
  fetch                    Fetch project
  up                       Start a project container
  down                     Stop a project container
  remove                   Remove a project
  update                   Pull latest changes
  status                   See project status
  list                     List all downloaded projects
```

### Http server

Run the server at port 8080:

```sh
ADAPTER=http lunch
```

```sh
# Example
curl localhost:8080/list
```

## Structure

Lunch follows a simple [DDD architecture](https://en.wikipedia.org/wiki/Domain-driven_design).

```
/Adapter        Adapters for domain actions
    Cli.hs          The CLI adapter. Handles arugment parsing and dispatching to domain usecases.
    Http.hs         The HTTP adapter. Runs a HTTP server at port 8080.

/Domain         Domain logic and types
    Model.hs        All domain models and types.
    Port.hs         Domain ports (dependencies)
    Usecase.hs      Domain usecases. Deployment, updates, etc.

/Infra          Implementation of domain ports
    Git.hs          Impl of GitRepo
    Docker.hs       Impl of DockerRepo
    Logger.hs       Impl of Logger
    Fs.hs           Impl of FsRepo

/Pkg
    IO.hs           Useful IO utils

Main.hs         Program entry point. Call bootstrap and adapter
Bootstrap.hs    Bootstrap all dependencies
```

