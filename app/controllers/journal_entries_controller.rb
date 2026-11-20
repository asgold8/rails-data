class JournalEntriesController < ApplicationController
  def create
    # No authentication yet: the client comes from the URL (see docs/decisions/0009).
    @client = Client.find(params[:client_id])
    @journal_entry = @client.journal_entries.build(journal_entry_params)

    if @journal_entry.save
      redirect_to @client, notice: "Journal entry posted."
    else
      render "clients/show", status: :unprocessable_content
    end
  end

  private

  def journal_entry_params
    params.expect(journal_entry: [ :body ])
  end
end
