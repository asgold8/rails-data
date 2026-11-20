---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Order journal entries by `created_at`, tie-broken by `id`

## Context and Problem Statement

Two required queries return journal entries "sorted by date". We need to decide which date, and how to keep the order stable when two entries share a timestamp.

## Decision Drivers

* The prompt doesn't mention a user-chosen date
* Ordering must be deterministic for tests and pagination
* The sort should be served by an index

## Considered Options

* `created_at DESC, id DESC`
* A client-chosen `entry_date` column (allows backdating)
* `created_at DESC` alone

## Decision Outcome

Chosen option: "`created_at DESC, id DESC`", exposed as `JournalEntry.recent_first`. "Date" means when the entry was written, which Rails already records. `id` breaks ties so equal timestamps always come back in the same order.

### Consequences

* Good, because no extra column or input field
* Good, because `[client_id, created_at]` index serves the per-client query
* Good, because `(created_at, id)` is a unique, stable key for keyset pagination (see [scaling notes](../scaling.md))
* Bad, because clients can't log something for a past day

## Pros and Cons of the Options

### `created_at, id`

* Good, because stable and zero extra input
* Bad, because it's "written at", not "about the day of"

### `entry_date`

* Good, because supports "yesterday I…" entries
* Bad, because one more field to validate and display; needs its own tie-breaker anyway

### `created_at` alone

* Good, because simplest
* Bad, because ties come back in an undefined order, which makes flaky tests and duplicated or skipped rows when paging

## More Information

Revisit if clients need to log past days; add `entry_date` (default today) and sort by `entry_date, created_at, id`.
