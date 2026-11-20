FactoryBot.define do
  factory :journal_entry do
    association :client
    body { "Ate well today" }
  end
end
