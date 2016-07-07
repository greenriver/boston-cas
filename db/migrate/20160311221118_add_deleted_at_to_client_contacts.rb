class AddDeletedAtToClientContacts < ActiveRecord::Migration
  def change
    add_column :client_contacts, :deleted_at, :datetime
    add_index :client_contacts, :deleted_at
  end
end
