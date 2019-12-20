class AddDeletedAtToDeidentifiedClients < ActiveRecord::Migration[4.2]
  def change
    add_column :deidentified_clients, :deleted_at, :datetime
    add_index :deidentified_clients, :deleted_at
  end
end
