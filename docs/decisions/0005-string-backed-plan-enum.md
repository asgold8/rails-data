---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# String-backed plan enum with a check constraint

## Context and Problem Statement

`Enrollment#plan` is one of a fixed set of values (`basic`, `premium`). Rails enums can be backed by integers or strings, and we want bad values rejected even if code bypasses validations.

## Decision Drivers

* Readable data when looking at the database directly
* Safe to add or reorder values later
* Integrity enforced in the database, not only in Ruby

## Considered Options

* String-backed enum + DB check constraint
* Integer-backed enum (Rails' classic default)
* A separate `plans` table with a foreign key

## Decision Outcome

Chosen option: "String-backed enum + DB check constraint", because `"premium"` in a row means what it says, and reordering the enum hash can't silently remap existing data. The check constraint `plan IN ('basic', 'premium')` is a backstop for `update_column`, raw SQL, or another app writing to the table.

### Consequences

* Good, because SQL queries, logs, and DB consoles are self-explanatory
* Good, because `enum ..., validate: true` gives a normal validation error instead of an `ArgumentError`
* Bad, because strings take a few more bytes than integers
* Bad, because adding a plan needs a migration to update the check constraint

## Pros and Cons of the Options

### String enum + check constraint

* Good, because readable and order-independent
* Bad, because the allowed list lives in two places (model and constraint)

### Integer enum

* Good, because compact
* Bad, because `2` means nothing without the code, and reordering the hash corrupts meaning

### `plans` lookup table

* Good, because plans could carry attributes (price, features)
* Bad, because overkill for two fixed values

## More Information

Revisit with a `plans` table if plans gain attributes such as price or billing period. Related: [0004](0004-plan-on-enrollment-join-model.md).
