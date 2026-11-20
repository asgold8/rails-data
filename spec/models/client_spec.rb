require "rails_helper"

RSpec.describe Client do
  it "requires a name" do
    expect(build(:client, name: "")).not_to be_valid
  end

  it "requires an email" do
    expect(build(:client, email: "")).not_to be_valid
  end

  it "rejects a duplicate email regardless of case" do
    create(:client, email: "carol@example.com")

    expect(build(:client, email: "Carol@Example.com")).not_to be_valid
  end

  it "removes its enrollments and journal entries when destroyed" do
    client = create(:client)
    create(:enrollment, client: client)
    create(:journal_entry, client: client)

    expect { client.destroy }
      .to change(Enrollment, :count).by(-1)
      .and change(JournalEntry, :count).by(-1)
  end
end
