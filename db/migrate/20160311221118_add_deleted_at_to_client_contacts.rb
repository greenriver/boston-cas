class AddDeletedAtToClientContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :client_contacts, :deleted_at, :datetime
    add_index :client_contacts, :deleted_at
  end
end
