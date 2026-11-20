require "rails_helper"

RSpec.describe JournalEntry do
  it "requires a body" do
    expect(build(:journal_entry, body: "")).not_to be_valid
  end
end
