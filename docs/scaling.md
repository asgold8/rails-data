# Scaling notes: what if the dataset were very large?

These notes aren't decisions yet. They're where the current design would bend first, and what we'd do about it.

## 1. The `[client_id, created_at]` index and its column order

`journal_entries` has a composite index on `(client_id, created_at)`. Column order matters: an index is sorted by its first column, then the second within it. So for one client, the entries are already stored in date order inside the index.

- `client.journal_entries.recent_first` → `WHERE client_id = ? ORDER BY created_at DESC, id DESC`. The database jumps to that client's slice and reads it backwards. No sort step. (In SQLite the index also carries the rowid, so even the `id` tie-break comes for free.)
- Because `client_id` is first, the same index also serves plain `WHERE client_id = ?` lookups, which is why there's no separate `client_id` index.
- `(created_at, client_id)` would be the wrong way round: it's good for "everything in a date range" but forces a scan to find one client's rows.

`enrollments` follows the same idea: the unique `(provider_id, client_id)` index covers "clients of a provider", and a separate `client_id` index covers "providers of a client".

## 2. Keyset (cursor) pagination instead of `OFFSET`

`LIMIT 20 OFFSET 100000` makes the database walk and throw away 100,000 rows, and rows shift between pages if new entries arrive. Instead, paginate from the last row seen:

```ruby
JournalEntry.recent_first
  .where("(created_at, id) < (?, ?)", last.created_at, last.id)
  .limit(20)
```

`(created_at, id)` is unique and matches the sort order ([ADR 0006](decisions/0006-journal-ordering-by-created-at.md)), so every page is an index range scan of 20 rows, no matter how deep. The trade-off is no "jump to page 57", only next/previous.

## 3. N+1 queries in the provider feed

Showing a provider's feed with each entry's client name:

```ruby
provider.journal_entries.recent_first.each { |e| e.client.name } # 1 query + 1 per entry
provider.journal_entries.recent_first.includes(:client)           # 2 queries total
```

Use `includes(:client)` (or `preload`) wherever entries are listed with client details. The client page doesn't have this problem because it shows a single client.

## 4. The provider feed join

`provider.journal_entries` is `enrollments → clients → journal_entries`, then a sort across all of those clients. For a provider with thousands of clients and millions of entries, the database has to gather each client's recent entries and merge them. The per-client index helps, but a full sort across clients is the expensive part.

Options, in rough order of effort:

1. **Paginate + limit** (section 2) so we only ever need the top N.
2. **Cache** the first page of each provider's feed, invalidated when one of their clients posts.
3. **Denormalized feed table**, e.g. `provider_feed_items (provider_id, journal_entry_id, created_at)` with an index on `(provider_id, created_at, id)`, written when an entry is posted (fan-out on write). Reads become one index range scan. Costs: write amplification, and backfill/cleanup when enrollments change.

## 5. Partitioning, and moving to Postgres first

At very large volume, partition `journal_entries` by time (e.g. monthly) so recent queries touch small partitions and old data can be archived cheaply. SQLite has no table partitioning, so this means moving to PostgreSQL first ([ADR 0003](decisions/0003-sqlite-for-prework.md)). Postgres would also give partial indexes (useful if we add soft-ended enrollments, [ADR 0007](decisions/0007-hard-delete-enrollments.md)) and better concurrent writes.

## 6. Unbounded `body` text

`body` is `text` with no limit. One client could post megabytes and slow every page and query that includes it. Add a length limit in both places, as with the other constraints:

```ruby
validates :body, length: { maximum: 10_000 }
# migration: check constraint "length(body) <= 10000"
```

The feed could also show a truncated preview and load the full body on demand.
