---
status: accepted
date: 2026-11-20
decision-makers: Alex
---

# No authentication in the pre-work

## Context and Problem Statement

The journal page takes the client from the URL (`/clients/:id`). Anyone can view any client's journal or post as them by changing the id. Authentication isn't part of the prompt, but the gap should be explicit.

## Decision Drivers

* Keep the pre-work focused on the data model
* Avoid half-built auth that looks secure but isn't
* Make the real-world fix clear

## Considered Options

* No authentication; client comes from the URL
* Rails 8 authentication generator for clients, plus authorization for providers

## Decision Outcome

Chosen option: "No authentication", because it's out of scope and adding a partial login flow would add code to explain without making the demo safer in a meaningful way. The gap is called out here and in a comment in `JournalEntriesController`.

### Consequences

* Good, because the demo stays small and easy to click through
* Bad, because **anyone can read or post as any client**; this must not ship as is

## Pros and Cons of the Options

### No auth

* Good, because zero extra code
* Bad, because no access control at all

### Rails 8 auth generator + authorization

* Good, because the current client comes from the session (`Current.user`), not the URL; routes become `resource :journal` (singular)
* Good, because provider reads can be authorized against enrollments
* Bad, because more code, sessions, and password handling to review

## More Information

In a real app: `bin/rails generate authentication`, scope client actions to the signed-in client, and authorize provider access through their enrollments (with the visibility rule from [0008](0008-provider-visibility-of-entries.md)).
