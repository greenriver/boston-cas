class ChangeContactsStructure < ActiveRecord::Migration[4.2]
  def change
    remove_column :contacts, :organization_name

  end
end
