class AddMiddleNameToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :middle_name, :string
  end
end
