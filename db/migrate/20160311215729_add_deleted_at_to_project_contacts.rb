class AddDeletedAtToProjectContacts < ActiveRecord::Migration
  def change
    add_column :project_contacts, :deleted_at, :datetime
    add_index :project_contacts, :deleted_at
  end
end
