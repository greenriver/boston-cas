class AddRoleToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :role, :string
  end
end
