require "rails_helper"

RSpec.describe Provider do
  it "requires a name" do
    expect(build(:provider, name: "")).not_to be_valid
  end

  it "requires an email" do
    expect(build(:provider, email: "")).not_to be_valid
  end

  it "rejects a duplicate email regardless of case" do
    create(:provider, email: "alice@example.com")

    expect(build(:provider, email: " ALICE@example.com ")).not_to be_valid
  end

  it "removes its enrollments when destroyed" do
    provider = create(:provider)
    create(:enrollment, provider: provider)

    expect { provider.destroy }.to change(Enrollment, :count).by(-1)
  end
end
