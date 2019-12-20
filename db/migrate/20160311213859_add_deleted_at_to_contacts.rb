class AddDeletedAtToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :deleted_at, :datetime
    add_index :contacts, :deleted_at
  end
end
