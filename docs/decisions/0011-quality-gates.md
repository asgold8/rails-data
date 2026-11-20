---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Keep the Rails 8.1 default quality gates

## Context and Problem Statement

Rails 8.1 generates style, security, and dependency checks, a local `bin/ci` runner, and a GitHub Actions workflow. We need to decide which to keep.

## Decision Drivers

* Catch style, security, and vulnerable-dependency issues before review
* Same checks locally and in CI
* Minimal configuration to explain

## Considered Options

* Keep all Rails defaults: RuboCop (omakase), Brakeman, bundler-audit, importmap audit, `bin/ci`, GitHub Actions
* Trim to tests only
* Add more tools (e.g. SimpleCov, extra RuboCop plugins)

## Decision Outcome

Chosen option: "Keep all Rails defaults", because they're free, conventional, and already wired together. `bin/ci` (configured in `config/ci.rb`) runs, in order: setup, RuboCop, bundler-audit, importmap audit, Brakeman, RSpec, and a seed check. CI runs the same tools as separate jobs.

### Consequences

* Good, because reviewers see a green, conventional pipeline
* Good, because Brakeman already paid off: it flagged a CVE in the originally installed Ruby (4.0.9), so we moved to 4.0.10
* Bad, because omakase style rules are opinionated and not up for debate per project

## Pros and Cons of the Options

### Rails defaults

* Good, because zero extra config
* Bad, because style rules may differ from the team's own RuboCop config

### Tests only

* Good, because faster
* Bad, because loses security and dependency scanning

### More tools

* Good, because more signal (coverage, extra cops)
* Bad, because more config and noise for a small pre-work app

## More Information

The CI test job runs on Linux and macOS, plus a Docker job (see [0012](0012-portability-and-dev-environment.md)). Testing choices are in [0010](0010-rspec-and-factory-bot.md).
