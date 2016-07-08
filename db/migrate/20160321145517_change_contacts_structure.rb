class ChangeContactsStructure < ActiveRecord::Migration
  def change
    remove_column :contacts, :organization_name

  end
end
