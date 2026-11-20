require "rails_helper"

RSpec.describe Enrollment do
  it "is invalid with an unknown plan" do
    enrollment = build(:enrollment, plan: "gold")

    expect(enrollment).not_to be_valid
    expect(enrollment.errors[:plan]).to be_present
  end

  it "is rejected by the database check constraint when validations are bypassed" do
    enrollment = create(:enrollment)

    expect { enrollment.update_column(:plan, "gold") }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it "is invalid when the provider/client pair already exists" do
    existing = create(:enrollment)
    duplicate = build(:enrollment, provider: existing.provider, client: existing.client)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:client_id]).to be_present
  end
end
