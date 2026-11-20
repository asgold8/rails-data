require "rails_helper"

RSpec.describe "Client journal", type: :system do
  before { driven_by(:rack_test) }

  let(:client) { create(:client, name: "Carol") }

  before do
    create(:journal_entry, client: client, body: "Older entry", created_at: 2.days.ago)
    create(:journal_entry, client: client, body: "Newer entry", created_at: 1.day.ago)
  end

  def entry_bodies
    all("#journal-entries li p").map(&:text)
  end

  it "shows the client's entries newest first" do
    visit client_path(client)

    expect(entry_bodies).to eq([ "Newer entry", "Older entry" ])
  end

  it "posts a new entry and lists it first" do
    visit client_path(client)
    fill_in "What's on your mind?", with: "Brand new entry"
    click_button "Post entry"

    expect(page).to have_text("Journal entry posted.")
    expect(entry_bodies).to eq([ "Brand new entry", "Newer entry", "Older entry" ])
  end

  it "shows a validation error for a blank entry and adds nothing" do
    visit client_path(client)
    click_button "Post entry"

    expect(page).to have_text("Body can't be blank")
    expect(entry_bodies).to eq([ "Newer entry", "Older entry" ])
  end
end
