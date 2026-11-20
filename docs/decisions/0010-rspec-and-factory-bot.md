---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# RSpec + FactoryBot, with rack_test system specs

## Context and Problem Statement

Rails defaults to Minitest with YAML fixtures. The interviewing team uses RSpec and FactoryBot. We need a test stack, and a way to run browser-level (system) specs that works the same on WSL, macOS, Docker, and CI.

## Decision Drivers

* Match the team's existing stack and conventions
* Each spec's data should be visible in the spec itself
* System specs must run identically everywhere, without installing a browser

## Considered Options

* RSpec + FactoryBot + Capybara (`rack_test` driver)
* Minitest + fixtures (Rails default)
* RSpec + FactoryBot + Capybara with a headless browser (Selenium or Cuprite)

## Decision Outcome

Chosen option: "RSpec + FactoryBot + Capybara with `rack_test`", because it matches the team, and factories keep the data in each spec (the query specs build their dataset with `let!` in one place). The journal page works without JavaScript, so `rack_test` (in-process, no browser) is enough.

### Consequences

* Good, because familiar to the team
* Good, because factories are minimal (no traits), so there's no hidden data
* Good, because system specs need no Chrome/driver, so runs are the same locally, in Docker, and in CI
* Bad, because two extra gems and some setup over the Rails default
* Bad, because `rack_test` can't test JavaScript behaviour

## Pros and Cons of the Options

### RSpec + FactoryBot + rack_test

* Good, because team-aligned and portable
* Bad, because no JS coverage

### Minitest + fixtures

* Good, because zero setup and fast
* Bad, because fixture data lives in YAML away from the test that uses it; not the team's stack

### Headless browser driver

* Good, because tests JavaScript
* Bad, because needs Chrome in every environment, and is slower and flakier

## More Information

Revisit when a page depends on JavaScript: add Cuprite (or Selenium) for those specs only. Note: `spec/rails_helper.rb` truncates the test DB before the suite, because `bin/ci`'s seed step and `db:prepare` can leave rows behind that transactional rollback won't remove.
