---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Ending a relationship hard-deletes the enrollment

## Context and Problem Statement

When a client stops working with a provider, the enrollment needs to go away. We can delete the row or mark it ended and keep it.

## Decision Drivers

* Keep the four required queries simple
* No billing or history requirement in the prompt
* Avoid a filter every query must remember

## Considered Options

* Hard delete the enrollment row
* Soft-end: an `ended_at` timestamp (or status) on the enrollment

## Decision Outcome

Chosen option: "Hard delete", because nothing in the prompt needs past enrollments, and soft-ending means every query (`provider.clients`, `client.providers`, the provider feed) needs an "active only" scope that's easy to forget.

### Consequences

* Good, because associations mean exactly "current relationships"
* Bad, because we lose history: who was enrolled when, and on which plan
* Bad, because after deletion the provider no longer sees that client's entries at all (see [0008](0008-provider-visibility-of-entries.md))

## Pros and Cons of the Options

### Hard delete

* Good, because simplest data and queries
* Bad, because no audit trail

### Soft-end with `ended_at`

* Good, because preserves history for billing, reporting, and audits
* Good, because could let a former provider keep read access to past entries
* Bad, because every association needs `where(ended_at: nil)`, and a unique index must allow re-enrollment after ending

## More Information

Revisit when billing, reporting, or audit history is needed. Then add `ended_at`, scope the `has_many :through` associations to active enrollments, and replace the unique index with a partial one (active rows only).
