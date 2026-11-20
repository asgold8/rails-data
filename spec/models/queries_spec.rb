require "rails_helper"

# The four queries from the prompt, against one small, deliberate dataset:
#
#   carol: alice (basic), bob (premium)
#   dan:   alice
#   erin:  bob
RSpec.describe "Provider/client queries" do
  let(:t) { Time.zone.parse("2026-01-15 12:00") }

  let!(:alice) { create(:provider, name: "Alice") }
  let!(:bob)   { create(:provider, name: "Bob") }

  let!(:carol) { create(:client, name: "Carol") }
  let!(:dan)   { create(:client, name: "Dan") }
  let!(:erin)  { create(:client, name: "Erin") }

  let!(:enrollments) do
    [
      create(:enrollment, provider: alice, client: carol, plan: "basic"),
      create(:enrollment, provider: bob,   client: carol, plan: "premium"),
      create(:enrollment, provider: alice, client: dan),
      create(:enrollment, provider: bob,   client: erin)
    ]
  end

  # let! runs in order, so ids ascend down this list.
  # - Entries tied at t - 1.day exercise the id tie-breaker, within one client (query 3)
  #   and across clients (query 4).
  # - carol_oldest is inserted last, so sorting by id alone would put it first.
  let!(:carol_tied_1) { create(:journal_entry, client: carol, created_at: t - 1.day) }
  let!(:carol_tied_2) { create(:journal_entry, client: carol, created_at: t - 1.day) }
  let!(:dan_tied)     { create(:journal_entry, client: dan,   created_at: t - 1.day) }
  let!(:carol_oldest) { create(:journal_entry, client: carol, created_at: t - 3.days) }
  let!(:dan_middle)   { create(:journal_entry, client: dan,   created_at: t - 2.days) }
  let!(:dan_newest)   { create(:journal_entry, client: dan,   created_at: t) }
  let!(:erin_entry)   { create(:journal_entry, client: erin,  created_at: t - 12.hours) }

  it "1. returns all clients for a given provider" do
    expect(alice.clients).to contain_exactly(carol, dan)
  end

  it "2. returns all providers for a given client" do
    expect(carol.providers).to contain_exactly(alice, bob)
  end

  it "3. returns a client's journal entries newest first, breaking ties by id" do
    expect(carol.journal_entries.recent_first).to eq([ carol_tied_2, carol_tied_1, carol_oldest ])
  end

  it "4. returns journal entries across a provider's clients newest first" do
    expect(alice.journal_entries.recent_first)
      .to eq([ dan_newest, dan_tied, carol_tied_2, carol_tied_1, dan_middle, carol_oldest ])
  end
end
