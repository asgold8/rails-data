class CreateJournalEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :journal_entries do |t|
      # No standalone client index: the composite index below starts with client_id.
      t.references :client, null: false, foreign_key: true, index: false
      t.text :body, null: false

      t.timestamps
    end
    add_index :journal_entries, [ :client_id, :created_at ]
  end
end
