---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# SQLite for the pre-work

## Context and Problem Statement

We need a database. Reviewers should be able to clone and run the app with no setup, but the schema should still enforce integrity (foreign keys, unique indexes, check constraints).

## Decision Drivers

* Zero-setup for reviewers (native or Docker)
* Real constraint support so integrity lives in the database
* Closeness to what a production app would use

## Considered Options

* SQLite (Rails 8 default)
* PostgreSQL

## Decision Outcome

Chosen option: "SQLite", because it needs no server, ships as a file, and supports everything this schema uses: NOT NULL, foreign keys, unique and composite indexes, and check constraints.

### Consequences

* Good, because `bin/setup` or `docker compose up` is all a reviewer needs
* Good, because the Compose file stays a single service (see [0012](0012-portability-and-dev-environment.md))
* Bad, because it's further from a typical production setup; some behaviours differ (e.g. type affinity, concurrency)

## Pros and Cons of the Options

### SQLite

* Good, because no server process, no credentials
* Good, because Rails 8 treats it as production-capable for small apps
* Bad, because one writer at a time
* Bad, because no partitioning, fewer index types

### PostgreSQL

* Good, because a common production choice, with richer features (partial indexes, partitioning, `jsonb`)
* Bad, because every reviewer needs a running server or an extra Compose service

## More Information

Revisit when we need concurrent writes at volume, or Postgres-specific features such as table partitioning for journal entries or partial indexes (see [scaling notes](../scaling.md)). The migrations use only portable constraints, so switching is mostly a config change.
