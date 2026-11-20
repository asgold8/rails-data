require "rails_helper"

RSpec.describe "Journal entries", type: :request do
  let(:client) { create(:client) }

  describe "POST /clients/:client_id/journal_entries" do
    it "creates an entry for the client in the URL and redirects to the client page" do
      expect {
        post client_journal_entries_path(client), params: { journal_entry: { body: "Slept well" } }
      }.to change(client.journal_entries, :count).by(1)

      expect(response).to redirect_to(client_path(client))
    end

    it "creates nothing and returns 422 when the body is blank" do
      expect {
        post client_journal_entries_path(client), params: { journal_entry: { body: "" } }
      }.not_to change(JournalEntry, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
