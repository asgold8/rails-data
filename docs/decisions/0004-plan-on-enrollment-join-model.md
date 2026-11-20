---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Plan lives on an Enrollment join model

## Context and Problem Statement

Providers have many clients and clients can have many providers. For *each* provider a client is signed up with, the client has a plan (`basic` or `premium`). We need to decide where the plan is stored.

## Decision Drivers

* A client can be basic with one provider and premium with another
* The many-to-many relationship must be queryable both ways
* Conventional Rails associations

## Considered Options

* An `Enrollment` model (provider_id, client_id, plan) with `has_many :through`
* `has_and_belongs_to_many` with a bare join table
* A `plan` column on `clients`

## Decision Outcome

Chosen option: "`Enrollment` join model with `has_many :through`", because the plan belongs to the *relationship*, not to the provider or the client. A join model is where relationship attributes go in Rails.

### Consequences

* Good, because each provider/client pair has its own plan
* Good, because a unique index on `[provider_id, client_id]` stops duplicate enrollments
* Good, because it gives the relationship a name we can hang future attributes on (start date, status)
* Bad, because one more model and table than HABTM

## Pros and Cons of the Options

### `has_many :through` an Enrollment model

* Good, because the join row is a real model with validations and attributes
* Bad, because slightly more code

### `has_and_belongs_to_many`

* Good, because the least code
* Bad, because the join table has no model, so it can't carry `plan` or validations

### `plan` column on clients

* Good, because simple
* Bad, because a client gets one plan for all providers, which breaks the requirement

## More Information

See [0005](0005-string-backed-plan-enum.md) for how `plan` is stored and [0007](0007-hard-delete-enrollments.md) for how an enrollment ends.
