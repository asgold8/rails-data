---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# Server-rendered Rails (ERB + Hotwire)

## Context and Problem Statement

The prompt is about the data model and four ActiveRecord queries. We still want a small UI to show a client's journal and post to it. We need to choose how the front end is built.

## Decision Drivers

* The prompt is data-model focused; UI is secondary
* Minimal moving parts for a reviewer to run
* Conventional Rails that's easy to explain

## Considered Options

* Full-stack Rails with server-rendered ERB (Hotwire defaults)
* SPA front end (React) talking to a GraphQL API (e.g. Apollo)
* `rails new --api` with JSON endpoints only

## Decision Outcome

Chosen option: "Full-stack Rails with server-rendered ERB", because a SPA adds a second build, a schema layer, and client state for no benefit to a data-model exercise. The page is one form and one list; a plain form POST and redirect covers it.

### Consequences

* Good, because one process, one language, Rails defaults throughout
* Good, because the page works without JavaScript, so tests need no browser (see [0010](0010-rspec-and-factory-bot.md))
* Bad, because if the product later needs a rich client or a public API, we'd add API endpoints then

## Pros and Cons of the Options

### Server-rendered ERB

* Good, because least code and fastest to review
* Good, because Turbo is there if we want partial page updates later
* Bad, because less interactive than a SPA out of the box

### React + GraphQL

* Good, because flexible client-driven queries and rich UI
* Bad, because two apps, a GraphQL schema, and N+1 concerns in resolvers, all for one page

### `--api`

* Good, because a clean JSON surface for other clients
* Bad, because no UI at all for the reviewer to click through

## More Information

Revisit if a mobile app or third party needs to consume the data, or if the UI grows beyond simple forms.
