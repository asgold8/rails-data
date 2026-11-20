class ClientsController < ApplicationController
  def index
    @clients = Client.order(:name)
  end

  def show
    @client = Client.find(params[:id])
    @journal_entry = JournalEntry.new
  end
end
