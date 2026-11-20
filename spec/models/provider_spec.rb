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
end
