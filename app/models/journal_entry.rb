class JournalEntry < ApplicationRecord
  belongs_to :client

  validates :body, presence: true
  scope :recent_first, -> { order(created_at: :desc, id: :desc) }
end
