---
status: proposed
date: 2026-11-20
decision-makers: Alex
---

# Which journal entries can a provider see?

## Context and Problem Statement

Query 4 returns "all journal entries across all clients of a given provider". As built, a provider sees *every* entry of each of their clients, including entries written before the enrollment began, and entries the client may have meant for a different provider. Journal entries are likely health data, so this is a privacy question, not just a query detail. **This needs a product decision.**

## Decision Drivers

* Client privacy and consent (health data)
* Providers need enough context to help the client
* Query and data-model simplicity

## Considered Options

* All of a client's entries (current behaviour)
* Only entries written since the enrollment started
* Entries scoped per provider (an entry belongs to an enrollment)

## Decision Outcome

Proposed option: "All of a client's entries", because it's the literal reading of the prompt and the simplest query (`has_many :journal_entries, through: :clients`). Flagged as `proposed` until product confirms.

### Consequences

* Good, because simple, and providers get full context
* Bad, because a new provider immediately sees the client's whole history
* Bad, because a client can't keep an entry private from one of their providers

## Pros and Cons of the Options

### All entries

* Good, because the simplest query
* Bad, because the widest exposure

### Entries since enrollment start

* Good, because nothing written before the relationship is visible
* Bad, because the query must join on `journal_entries.created_at >= enrollments.created_at`, and hard deletes ([0007](0007-hard-delete-enrollments.md)) lose the start date when a relationship ends and restarts

### Entries scoped per provider

* Good, because clients control exactly who sees what
* Bad, because the client must choose an audience for each entry; the model changes to `journal_entry belongs_to :enrollment` (or a visibility join table)

## More Information

Questions for product: Should clients be able to hide entries? Should a new provider see history? Is consent recorded? Related: [0009](0009-no-authentication-in-prework.md) (no auth means visibility isn't enforced yet anyway).
