---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Record architecture decisions

## Context and Problem Statement

This app makes a number of small but deliberate choices (data model, database, testing, tooling). Reviewers will ask "why this and not that?", and the reasoning is easy to lose if it only lives in chat or in someone's head. We need a lightweight, durable place to write it down.

## Decision Drivers

* Reasoning should sit next to the code it explains and be versioned with it
* Low ceremony: a short Markdown file, not a wiki or a design doc
* A consistent shape so each record is quick to read

## Considered Options

* MADR (Markdown Architectural Decision Records) in `docs/decisions/`
* Comments in the code and commit messages only
* An external wiki or doc

## Decision Outcome

Chosen option: "MADR in `docs/decisions/`", because it keeps decisions in the repo, reviewed in the same PRs as the code, with a template that forces listing alternatives and consequences.

### Consequences

* Good, because anyone cloning the repo sees the "why", not just the "what"
* Good, because the template makes trade-offs explicit
* Bad, because records can drift from the code if nobody updates them when a decision changes

## Pros and Cons of the Options

### MADR in the repo

* Good, because versioned and reviewed with the code
* Good, because a widely used, simple template
* Bad, because one more thing to maintain

### Code comments and commit messages only

* Good, because zero extra files
* Bad, because comments explain *what*, rarely the rejected alternatives; commit history is hard to browse by topic

### External wiki

* Good, because easy to edit for non-engineers
* Bad, because it drifts from the code and isn't tied to a commit

## More Information

When a decision changes, add a new ADR that supersedes the old one and set the old one's status to `superseded by NNNN`, rather than rewriting history.
