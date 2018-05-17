class AddDeletedAtToDeidentifiedClients < ActiveRecord::Migration
  def change
    add_column :deidentified_clients, :deleted_at, :datetime
    add_index :deidentified_clients, :deleted_at
  end
end
