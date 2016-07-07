class AddFieldsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :role_id, :integer
    add_column :contacts, :role_in_organization, :string
    add_column :contacts, :workphone, :string
    add_column :contacts, :cellphone, :string
  end
end
