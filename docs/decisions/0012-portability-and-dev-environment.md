---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Portability: Docker Compose for reviewers, native Ruby for development

## Context and Problem Statement

The app is developed on WSL2 (x86_64 Linux) and will be reviewed on Macs, likely Apple Silicon (arm64). A reviewer should get a running app with as little setup as possible, and we want proof that it works on both platforms.

## Decision Drivers

* One command for a reviewer who only has Docker
* Works on x86_64 and arm64
* Day-to-day development stays fast and native
* Proof in CI, not just "works on my machine"

## Considered Options

* Native Ruby only
* Docker Compose (one service) for reviewers + native for development
* Devcontainer
* Tilt

## Decision Outcome

Chosen option: "Docker Compose + native", because `docker compose up --build` gives a seeded app at http://localhost:3000 on any platform via the multi-arch official `ruby` image, while developers keep native tools. CI proves it: specs on `ubuntu-latest` and `macos-latest`, plus a job that builds the image and runs specs inside it.

### Consequences

* Good, because reviewers need only Docker; developers need only the Ruby in `.ruby-version`
* Good, because code is copied into the image, not bind-mounted, so no root-owned files or stale `server.pid` in the checkout
* Bad, because code changes need `docker compose up --build` in the Docker path
* Bad, because `Dockerfile.dev`'s `RUBY_VERSION` must be kept in sync with `.ruby-version` by hand

Supporting measures: `Gemfile.lock` includes Linux and macOS platforms (x86_64 and arm64) so native gems like `sqlite3` resolve everywhere; `.gitattributes` forces LF line endings so `bin/*` scripts work regardless of host git settings; `.ruby-version` pins Ruby for version managers and `ruby/setup-ruby`.

## Pros and Cons of the Options

### Native only

* Good, because simplest
* Bad, because reviewers must install a specific Ruby (macOS system Ruby is too old)

### Compose + native

* Good, because covers both audiences
* Bad, because two run paths to keep working (CI checks both)

### Devcontainer

* Good, because a full editor environment in a container
* Bad, because effectively ties reviewers to VS Code

### Tilt

* Good, because great for live-reloading multi-service or Kubernetes setups
* Bad, because overkill for a single Rails process with SQLite

## More Information

Revisit when the app gains services (Postgres per [0003](0003-sqlite-for-prework.md), a job worker): add them to `compose.yaml`.
