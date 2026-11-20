# Demo data for exploring the four queries in `bin/rails console`.
# Idempotent: find_or_create_by! makes it safe to run more than once.

providers = {
  alice: Provider.find_or_create_by!(email: "alice@example.com") { |p| p.name = "Dr. Alice Moreno" },
  bob: Provider.find_or_create_by!(email: "bob@example.com") { |p| p.name = "Dr. Bob Chen" },
  priya: Provider.find_or_create_by!(email: "priya@example.com") { |p| p.name = "Priya Shah, RD" }
}

clients = {
  carol: Client.find_or_create_by!(email: "carol@example.com") { |c| c.name = "Carol Diaz" },
  dan: Client.find_or_create_by!(email: "dan@example.com") { |c| c.name = "Dan Okafor" },
  erin: Client.find_or_create_by!(email: "erin@example.com") { |c| c.name = "Erin Walsh" },
  frank: Client.find_or_create_by!(email: "frank@example.com") { |c| c.name = "Frank Ito" },
  grace: Client.find_or_create_by!(email: "grace@example.com") { |c| c.name = "Grace Lee" }
}

[
  [ :alice, :carol, "basic" ],
  [ :bob, :carol, "premium" ],   # carol has two providers
  [ :alice, :dan, "premium" ],
  [ :bob, :erin, "basic" ],
  [ :priya, :frank, "premium" ],
  [ :priya, :grace, "basic" ],
  [ :alice, :grace, "basic" ]    # grace has two providers
].each do |provider, client, plan|
  Enrollment.find_or_create_by!(provider: providers[provider], client: clients[client]) { |e| e.plan = plan }
end

entries = {
  carol: [ "Slept eight hours, felt rested.", "Skipped breakfast, energy dipped by noon.", "Walked 30 minutes after dinner." ],
  dan: [ "Started tracking water intake.", "Knee felt better after stretching." ],
  erin: [ "Stressful day at work, ate late.", "Tried the new meal plan.", "Good run this morning." ],
  frank: [ "Cut back on coffee.", "Headache in the afternoon." ],
  grace: [ "Meal-prepped lunches for the week.", "Felt anxious before the appointment." ]
}

entries.each_with_index do |(client, bodies), client_index|
  bodies.each_with_index do |body, i|
    clients[client].journal_entries.find_or_create_by!(body: body) do |entry|
      entry.created_at = (bodies.size - i).days.ago - client_index.hours
    end
  end
end

puts <<~TEXT
  Seeded #{Provider.count} providers, #{Client.count} clients, #{Enrollment.count} enrollments, #{JournalEntry.count} journal entries.

  Try these in `bin/rails console`:
    alice = Provider.find_by!(email: "alice@example.com")
    carol = Client.find_by!(email: "carol@example.com")

    alice.clients                           # 1. all clients for a provider
    carol.providers                         # 2. all providers for a client
    carol.journal_entries.recent_first      # 3. a client's entries, newest first
    alice.journal_entries.recent_first      # 4. entries across a provider's clients, newest first
TEXT
